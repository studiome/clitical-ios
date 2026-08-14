#!/bin/sh
#
# Xcode Cloud runs this script right before each xcodebuild invocation.
#
# Why it exists: on the shared Xcode Cloud VM the legacy simulator runtimes
# (iOS 16 and earlier) boot slowly, and when several test destinations start at
# the same time the XCTest runner never connects inside its timeout window:
#
#   clitical-iosUITests-Runner encountered an error
#   (The test runner hung before establishing connection.)
#
# The same tests pass on iOS 26 in Xcode Cloud and on a local iOS 16 simulator,
# so the failure is cold-boot latency, not app or test code. Booting those
# devices here moves the boot out of the runner's connection timeout.

set -u

# Only relevant for the test machines; skip for archive/build/analyze actions.
case "${CI_XCODEBUILD_ACTION:-}" in
    test|test-without-building) ;;
    *) exit 0 ;;
esac

# UDIDs of the available devices whose runtime is iOS 16 or older. Newer
# runtimes boot fast enough that pre-booting them would only add contention.
legacy_udids=$(xcrun simctl list devices available | awk '
    /^-- / { legacy = ($0 ~ /iOS 1[0-6]\./); next }
    legacy && match($0, /\([0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+-[0-9A-Fa-f]+\)/) {
        print substr($0, RSTART + 1, RLENGTH - 2)
    }
')

if [ -z "$legacy_udids" ]; then
    echo "ci_pre_xcodebuild: no legacy simulator runtimes on this machine, nothing to pre-boot."
    exit 0
fi

# An Xcode Cloud test machine only has the devices for its own destinations. A
# long list means we are somewhere else (a developer Mac full of simulators),
# where booting all of them would hurt more than the cold boot it avoids.
legacy_count=$(echo "$legacy_udids" | wc -l | tr -d ' ')
if [ "$legacy_count" -gt 4 ]; then
    echo "ci_pre_xcodebuild: $legacy_count legacy simulators found, skipping pre-boot."
    exit 0
fi

pids=""
for udid in $legacy_udids; do
    echo "ci_pre_xcodebuild: pre-booting simulator $udid"
    xcrun simctl bootstatus "$udid" -b >/dev/null 2>&1 &
    pids="$pids $!"
done

# Wait for the boots, but never longer than the test action can afford. A
# simulator that is still booting is not a reason to fail the build: xcodebuild
# gets its usual chance to boot it.
deadline=$(($(date +%s) + 300))
for pid in $pids; do
    while kill -0 "$pid" 2>/dev/null; do
        if [ "$(date +%s)" -ge "$deadline" ]; then
            echo "ci_pre_xcodebuild: pre-boot exceeded 300s, continuing without it."
            kill "$pid" 2>/dev/null
            break
        fi
        sleep 5
    done
done

echo "ci_pre_xcodebuild: legacy simulators pre-booted."
exit 0
