//
//  cliticalUITests.swift
//  cliticalUITests
//
//  Created by kmiyahara on 2022/12/20.
//

import XCTest

/// Launch arguments that start the app past the first-run intended-use notice,
/// which these tests are not about. Mirrors
/// `IntendedUseDisclaimer.currentVersion` in the app target, which the UI test
/// bundle cannot import; bump both together.
let acknowledgedDisclaimerArguments = [
    "-intended_use_disclaimer_version", "2026-08",
]

/// What an empty age field reports. The fields carry an example value as their
/// placeholder so an untouched row reads as an input field rather than as
/// blank space, and XCUITest surfaces that placeholder as the field's value.
/// Tests therefore enter a different age (`enteredAge`) so that a typed value
/// can be told apart from the placeholder.
let emptyAgeFieldValue = "70"
let enteredAge = "68"

/// The language the app resolves from the system. The app no longer has an
/// in-app language switch, so tests choose a language the way a user does
/// with the per-app language setting: through the launch-time system keys.
let englishArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
let japaneseArguments = ["-AppleLanguages", "(ja)", "-AppleLocale", "ja_JP"]

final class cliticalUITests: XCTestCase {

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // cliticalUITestsLaunchTests runs for every target application UI
        // configuration, which leaves the device in whatever orientation the
        // last configuration used — landscape, if that run came first. These
        // tests scroll by dragging normalized screen coordinates, so their
        // geometry must not depend on which tests ran before them.
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// The intended-use notice stands in front of the app until it is
    /// acknowledged: no risk form, no tabs, no calculated values.
    func testIntendedUseNoticeGatesTheAppUntilAcknowledged() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        // Force the notice regardless of what an earlier run on this simulator
        // acknowledged: the argument domain wins over the persisted value.
        app.launchArguments += ["-intended_use_disclaimer_version", "unacknowledged"]
        app.launch()

        let notice = app.descendants(matching: .any)
            .matching(identifier: "intendedUseNotice")
            .firstMatch
        XCTAssertTrue(notice.waitForExistence(timeout: 5),
                      "Intended-use notice did not appear on launch")
        XCTAssertTrue(app.buttons["acknowledgeDisclaimer"].waitForExistence(timeout: 5),
                      "Acknowledgement button is missing from the notice")
        XCTAssertFalse(topLevelItem("Risk Assessment", in: app).exists,
                       "The app is reachable before the notice is acknowledged")
    }

    /// There is no in-app language switch any more: the app follows the
    /// system per-app language. The tabs localize from the launch language,
    /// and Settings offers a row that opens the app's page in iOS Settings
    /// (not tapped here, as it would leave the app).
    func testSettingsOffersSystemLanguageSettingsRow() throws {
        let app = XCUIApplication()
        app.launchArguments += japaneseArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        // Three top-level destinations, in the launch language. On iPad and
        // newer OSes these may be exposed as sidebar items instead of a
        // bottom tab bar.
        for label in ["リスク計算", "参考文献", "設定"] {
            XCTAssertTrue(topLevelItem(label, in: app).waitForExistence(timeout: 5),
                          "Missing tab: \(label)")
        }
        XCTAssertTrue(app.staticTexts["患者基本情報"].waitForExistence(timeout: 5),
                      "Section header did not follow the launch language")

        tapTopLevelItem("設定", in: app)
        let languageRow = app.buttons["openLanguageSettings"]
        XCTAssertTrue(languageRow.waitForExistence(timeout: 5),
                      "Settings must offer a row that opens the system language setting")
        XCTAssertEqual(languageRow.label, "言語設定を開く")
        // The old in-app picker must be gone.
        XCTAssertFalse(app.buttons["English"].exists)
        XCTAssertFalse(app.switches["English"].exists)
    }

    /// Verifies the References and Settings tabs render their content and links.
    func testReferencesAndSettingsTabsRenderContent() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        tapTopLevelItem("References", in: app)
        XCTAssertTrue(app.staticTexts["Opens the article on doi.org."].waitForExistence(timeout: 5))
        let citation = app.descendants(matching: .any)
            .containing(NSPredicate(format: "label BEGINSWITH %@", "1. Miyata")).firstMatch
        XCTAssertTrue(citation.waitForExistence(timeout: 5), "Reference citation missing")

        tapTopLevelItem("Settings", in: app)
        let languageRow = app.buttons["openLanguageSettings"]
        XCTAssertTrue(languageRow.waitForExistence(timeout: 5),
                      "Language row missing from Settings")
        XCTAssertEqual(languageRow.label, "Open Language Settings")
        // Legal and support actions may be rendered as buttons or links
        // depending on the OS version, so query by label across all elements.
        for label in ["Terms of Use", "Privacy Policy", "Support"] {
            let action = app.descendants(matching: .any)
                .matching(NSPredicate(format: "label == %@", label))
                .firstMatch
            scrollTo(action, in: app)
            XCTAssertTrue(action.waitForExistence(timeout: 5),
                          "Missing Settings action: \(label)")
        }
        let appVersionLabel = app.staticTexts["CLiTICAL"]
        scrollTo(appVersionLabel, in: app)
        XCTAssertTrue(appVersionLabel.waitForExistence(timeout: 5),
                      "App version is missing from Settings")
    }

    /// On iPad with NavigationSplitView, changing the selected section must
    /// not recreate the risk form and discard patient input.
    func testSwitchingSectionsPreservesPatientData() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        fillAgeField(in: app)
        tapTopLevelItem("References", in: app)
        XCTAssertTrue(app.staticTexts["Opens the article on doi.org."].waitForExistence(timeout: 5))

        tapTopLevelItem("Risk Assessment", in: app)
        let ageField = app.textFields["Age years"]
        scrollUpTo(ageField, in: app)
        XCTAssertEqual(ageField.value as? String, enteredAge,
                       "Changing sections must preserve entered patient data")
    }

    // NOTE: There is deliberately no test that tapping a reference citation or
    // the Terms of service button opens SFSafariViewController. The browser
    // does open, but it renders in a separate remote process
    // (SafariViewService) whose controls are exposed to XCUITest as unlabeled
    // elements — and iOS 26 removed the "Done" text button from its chrome —
    // so there is no stable element to assert on or to dismiss it with.

    /// Smoke test that the risk-calculation tab's form is interactive inside the
    /// TabView: predicting with an empty form surfaces the validation alert.
    func testRiskCalculationTabPredictShowsValidationAlert() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        tapTopLevelItem("Risk Assessment", in: app)
        // The Predict button sits at the bottom of a long scrolling form.
        let predict = app.buttons["predictRisks"]
        scrollTo(predict, in: app)
        XCTAssertTrue(predict.waitForExistence(timeout: 5), "Predict button missing")
        predict.tap()

        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 5),
                      "Validation alert did not appear")
    }

    /// Numeric input must remain visible and large enough to operate when
    /// people choose an accessibility Dynamic Type size.
    func testAccessibilityExtraLargeTextKeepsNumberFieldsUsable() throws {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL",
        ]
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        for label in ["Age years", "Height cm", "Weight kg", "Albumin g/dL"] {
            let field = app.textFields[label]
            scrollIntoTappableArea(field, in: app)
            XCTAssertTrue(field.waitForExistence(timeout: 5), "Missing field: \(label)")
            XCTAssertGreaterThanOrEqual(
                field.frame.width,
                44,
                "\(label) needs a visible, tappable input area at accessibility text sizes"
            )
        }
    }

    /// A validation alert must name the first missing numeric field so people
    /// can recover without searching the entire form.
    func testPredictWithEmptyFormNamesFirstMissingNumberField() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        tapPredictButton(in: app)

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Validation alert did not appear")
        XCTAssertTrue(
            alert.staticTexts["Enter a value for Age (years)."].exists,
            "The alert should name the first field that needs attention"
        )
    }

    /// Validation walks the form from the top, so the question after age is
    /// sex — which has no default and must be answered explicitly.
    func testPredictWithOnlyAgeNamesSexAsNextMissingAnswer() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        fillAgeField(in: app)
        tapPredictButton(in: app)

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Validation alert did not appear")
        XCTAssertTrue(
            alert.staticTexts["Choose a value for Sex."].exists,
            "The alert should name the next unanswered question"
        )
    }

    func testPredictWithAgeAndSexNamesHeightAsNextMissingNumberField() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        fillAgeField(in: app)
        selectSex("Male", in: app)
        tapPredictButton(in: app)

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Validation alert did not appear")
        XCTAssertTrue(
            alert.staticTexts["Enter a value for Height (cm)."].exists,
            "The alert should name the next missing field"
        )
    }

    /// The regression this whole range check exists for: a height typed in
    /// metres used to produce a plausible looking risk instead of an error.
    func testHeightEnteredInMetresIsRejected() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        fillAgeField(in: app)
        selectSex("Male", in: app)
        fillNumberField("Height cm", with: "1.7", in: app)
        fillNumberField("Weight kg", with: "60", in: app)
        fillNumberField("Albumin g/dL", with: "3.5", in: app)
        setToggle(row: "Infrapopliteal", to: "Yes", in: app)
        tapPredictButton(in: app)

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5),
                      "A height of 1.7 cm must not produce a prediction")
        XCTAssertFalse(app.staticTexts["Geriatric Nutritional Risk Index"].exists,
                       "No risk value may be shown for an out-of-range height")
    }

    /// Happy path: filling every required field and marking one artery lesion
    /// pushes the predicted-risk screen with the 2-year and GNRI results.
    func testPredictWithValidDataShowsRiskResults() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        fillRequiredFields(in: app)
        setToggle(row: "Infrapopliteal", to: "Yes", in: app)

        tapPredictButton(in: app)

        // On compact width (iPhone) the results are pushed as a dedicated
        // "Predicted Risks" screen. On regular width (iPad) they render inline
        // in the preview pane — no navigation bar. Assert the content texts
        // directly so the test covers both layouts.
        let twoYearTitle = app.staticTexts["Predicted 2-year Overall Survival"]
        scrollTo(twoYearTitle, in: app)
        XCTAssertTrue(twoYearTitle.waitForExistence(timeout: 5),
                      "Predicted 2-year Overall Survival did not appear")
        let gnriTitle = app.staticTexts["Geriatric Nutritional Risk Index"]
        scrollTo(gnriTitle, in: app)
        XCTAssertTrue(gnriTitle.waitForExistence(timeout: 5),
                      "Geriatric Nutritional Risk Index did not appear")
    }

    /// On regular-width layouts, changing patient data after prediction must
    /// remove the now-stale result from the preview pane.
    func testEditingPatientDataClearsPredictedRiskPreview() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        let emptyPreviewMessage = app.staticTexts[
            "Enter the patient data to show the predicted risks here."
        ]
        guard emptyPreviewMessage.waitForExistence(timeout: 2) else {
            throw XCTSkip("The predicted-risk preview is only present in regular width")
        }

        fillRequiredFields(in: app)
        setToggle(row: "Infrapopliteal", to: "Yes", in: app)
        tapPredictButton(in: app)

        let twoYearTitle = app.staticTexts["Predicted 2-year Overall Survival"]
        XCTAssertTrue(twoYearTitle.waitForExistence(timeout: 5),
                      "Predicted risk did not appear before editing")

        setToggle(row: "Congestive heart failure", to: "Yes", in: app)

        XCTAssertFalse(twoYearTitle.waitForExistence(timeout: 1),
                       "Editing patient data must remove the stale predicted risk")
        XCTAssertTrue(
            emptyPreviewMessage.waitForExistence(timeout: 5),
            "The empty prediction state did not return after editing"
        )
    }

    /// The urgency question is two independent named states (urgent vs.
    /// elective revascularization), not an on/off mechanism, so per HIG it
    /// must be an inline segmented control with both options visibly
    /// labeled — matching the pattern already used for Sex.
    func testUrgencyQuestionIsSegmentedControlWithBothLabels() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        tapTopLevelItem("Risk Assessment", in: app)

        let urgent = app.buttons["Urgent"]
        scrollTo(urgent, in: app)
        XCTAssertTrue(urgent.waitForExistence(timeout: 5),
                      "Urgency segmented option 'Urgent' missing")
        let elective = app.buttons["Elective"]
        XCTAssertTrue(elective.exists,
                      "Urgency segmented option 'Elective' missing")
        // Elective is the default state, so it leads the control.
        XCTAssertLessThan(elective.frame.minX, urgent.frame.minX,
                          "Elective must come before Urgent")
    }

    /// With valid numbers but no artery lesion selected, predicting must show
    /// the lesion-specific validation alert instead of the risk screen.
    func testPredictWithoutLesionShowsLesionAlert() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        fillRequiredFields(in: app)
        tapPredictButton(in: app)

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Validation alert did not appear")
        XCTAssertTrue(alert.staticTexts["Check the artery lesion sites. At least one lesion must be turned on."].exists,
                      "Alert should explain that at least one lesion is required")
        XCTAssertFalse(app.navigationBars["Predicted Risks"].exists)
    }

    /// A height typed in metres is flagged right under the field, as soon as
    /// it is entered, without waiting for a Predict attempt.
    func testOutOfRangeHeightShowsInlineErrorWithoutPredicting() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        fillNumberField("Height cm", with: "1.7", in: app)

        let inlineError = inlineMessage("heightInlineError", in: app)
        XCTAssertTrue(inlineError.waitForExistence(timeout: 5),
                      "An out-of-range height must show an inline error immediately")
        XCTAssertTrue(inlineError.label.contains("100"),
                      "The inline error should state the accepted range")
        XCTAssertFalse(app.alerts.firstMatch.exists,
                       "Inline validation must not raise the alert by itself")
    }

    /// After a failed Predict attempt, an empty required field says so inline.
    func testFailedPredictShowsRequiredHintUnderAge() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        XCTAssertFalse(inlineMessage("ageInlineError", in: app).exists,
                       "No required hint before any Predict attempt")
        tapPredictButton(in: app)
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Validation alert did not appear")
        alert.buttons.firstMatch.tap()

        let hint = inlineMessage("ageInlineError", in: app)
        scrollUpTo(hint, in: app)
        XCTAssertTrue(hint.waitForExistence(timeout: 5),
                      "A required hint should appear under the empty Age field")
        XCTAssertTrue(hint.label.contains("Required"))
    }

    /// The primary action must not require scrolling a long form: it is also
    /// in the navigation bar.
    func testPredictToolbarButtonIsReachableWithoutScrolling() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        let toolbarPredict = app.buttons["predictRisksToolbar"]
        XCTAssertTrue(toolbarPredict.waitForExistence(timeout: 5),
                      "Predict button missing from the navigation bar")
        toolbarPredict.tap()
        XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 5),
                      "Toolbar Predict must run the same validation as the list button")
    }

    /// In a compact-height window (iPhone landscape) the acknowledge button
    /// must not sit in a bottom bar that eats the little height there is; it
    /// scrolls with the notice and must still be reachable. iPhone only: iPad
    /// landscape is still regular height, where the bottom bar is correct.
    func testDisclaimerAcknowledgeIsReachableInLandscape() throws {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            throw XCTSkip("Only iPhone landscape has compact height")
        }
        XCUIDevice.shared.orientation = .landscapeLeft
        addTeardownBlock { XCUIDevice.shared.orientation = .portrait }
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += ["-intended_use_disclaimer_version", "unacknowledged"]
        app.launch()

        // The button is the last row of the notice's list, so it only exists
        // once scrolled to (and, being a list row, it scrolls: a bottom bar
        // would already be on screen from the start).
        let acknowledge = app.buttons["acknowledgeDisclaimer"]
        let list = app.collectionViews.firstMatch
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        let windowFrame = app.windows.firstMatch.frame
        XCTAssertFalse(acknowledge.exists,
                       "In compact height the button must not be a bottom bar")
        var swipes = 0
        while !(acknowledge.exists && windowFrame.contains(acknowledge.frame)) && swipes < 12 {
            list.swipeUp()
            swipes += 1
        }
        XCTAssertTrue(acknowledge.exists && windowFrame.contains(acknowledge.frame),
                      "Acknowledge button must be reachable by scrolling in landscape")
        // Not tapped: the launch argument that forces the notice also pins
        // the stored value, so acknowledging could not lead anywhere here.
    }

    /// Reset is destructive, so it must ask for confirmation first: cancelling
    /// keeps the entered data, confirming clears it.
    func testResetAsksForConfirmationBeforeClearingData() throws {
        let app = XCUIApplication()
        app.launchArguments += englishArguments
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        fillAgeField(in: app)

        let reset = app.buttons["Reset data"]
        scrollDownTo(reset, in: app)
        XCTAssertTrue(reset.waitForExistence(timeout: 5), "Reset button missing")
        reset.tap()

        // In compact size class the dialog is an action sheet with a Cancel
        // button; in regular size class (e.g. iPhone in landscape) SwiftUI
        // renders it as a popover with no dismiss action — the user taps
        // outside to dismiss. Verify appearance via the title text, which is
        // stable across both presentation styles.
        XCTAssertTrue(
            app.staticTexts["Reset all entered data?"].waitForExistence(timeout: 5),
            "Reset confirmation dialog did not appear"
        )
        let cancel = cancelConfirmationButton(in: app)
        if cancel.exists {
            cancel.tap()
        } else {
            // Regular size class: popover has no Cancel button; tap outside.
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1)).tap()
        }

        let ageField = app.textFields["Age years"]
        scrollUpTo(ageField, in: app)
        XCTAssertEqual(ageField.value as? String, enteredAge,
                       "Dismissing the confirmation must not clear the data")

        // Confirming must clear the data (the placeholder shows again).
        scrollDownTo(reset, in: app)
        reset.tap()
        XCTAssertTrue(
            app.staticTexts["Reset all entered data?"].waitForExistence(timeout: 5),
            "Reset confirmation dialog did not appear"
        )
        resetConfirmationButton(in: app).tap()

        scrollUpTo(ageField, in: app)
        XCTAssertEqual(ageField.value as? String, emptyAgeFieldValue,
                       "Confirming the dialog must clear the data")
    }

    // MARK: - Helpers

    /// An inline validation message, found by identifier across element types
    /// since it is exposed as a single combined element.
    private func inlineMessage(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func topLevelItem(_ label: String, in app: XCUIApplication) -> XCUIElement {
        let tabButton = app.tabBars.buttons[label]
        if tabButton.exists {
            return tabButton
        }
        if let identifier = appSectionIdentifier(for: label) {
            let sidebarButton = app.buttons.matching(identifier: identifier).firstMatch
            if sidebarButton.exists {
                return sidebarButton
            }
            let sidebarCell = app.cells.matching(identifier: identifier).firstMatch
            if sidebarCell.exists {
                return sidebarCell
            }
        }
        let sidebarButton = app.buttons
            .matching(NSPredicate(format: "label CONTAINS %@", label))
            .firstMatch
        if sidebarButton.exists {
            return sidebarButton
        }
        return app.cells
            .matching(NSPredicate(format: "label CONTAINS %@", label))
            .firstMatch
    }

    private func appSectionIdentifier(for label: String) -> String? {
        switch label {
        case "Risk Assessment", "リスク計算":
            "riskCalculation"
        case "References", "参考文献":
            "references"
        case "Settings", "設定":
            "settings"
        default:
            nil
        }
    }

    private func tapTopLevelItem(_ label: String, in app: XCUIApplication) {
        let item = topLevelItem(label, in: app)
        XCTAssertTrue(item.waitForExistence(timeout: 5), "Missing top-level item: \(label)")
        item.tap()
    }

    /// Scrolls the patient-data form down in small increments until the
    /// element appears in the accessibility tree.
    ///
    /// The form container is re-queried every iteration so a SwiftUI layout
    /// update that replaces the underlying collection view mid-scroll does not
    /// leave a stale element reference.  Container-relative coordinates keep
    /// the gesture inside the form column on both iPhone (full-width) and iPad
    /// (where the right portion of RootContentView is the risk-preview pane).
    ///
    /// On iOS 26, isHittable can return false for on-screen elements whose
    /// activation point has not yet been materialized, so the loop stops on
    /// existence alone — matching scrollUpTo's behaviour.
    private func scrollTo(
        _ element: XCUIElement,
        in app: XCUIApplication,
        maxSwipes: Int = 40
    ) {
        var swipes = 0
        while !element.exists && swipes < maxSwipes {
            let container = patientFormContainer(in: app)
            let start = container.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
            let end   = container.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            start.press(forDuration: 0.05, thenDragTo: end)
            swipes += 1
        }
    }

    /// The band of the window that no bar is covering.
    ///
    /// A List's rows keep existing in the accessibility tree while they scroll
    /// underneath the tab bar, so "the element exists" does not mean a tap will
    /// reach it — see `scrollIntoTappableArea`.
    private func unobstructedBounds(in app: XCUIApplication) -> (top: CGFloat, bottom: CGFloat) {
        let window = app.windows.firstMatch.frame
        var top = window.minY
        var bottom = window.maxY
        let navigationBar = app.navigationBars.firstMatch
        if navigationBar.exists {
            top = max(top, navigationBar.frame.maxY)
        }
        for bar in [app.tabBars.firstMatch, app.keyboards.firstMatch] where bar.exists {
            bottom = min(bottom, bar.frame.minY)
        }
        return (top, max(top, bottom))
    }

    /// Drags the form content between two absolute y positions.
    ///
    /// The x stays in the middle of the form column so the gesture does not
    /// land in the risk-preview pane that sits beside the form on iPad, and
    /// callers pass y positions taken from `unobstructedBounds` so the drag
    /// itself never starts on the keyboard or a bar.
    private func dragForm(in app: XCUIApplication, fromY: CGFloat, toY: CGFloat) {
        let x = patientFormContainer(in: app).frame.midX
        let origin = app.coordinate(withNormalizedOffset: .zero)
        let start = origin.withOffset(CGVector(dx: x, dy: fromY))
        let end = origin.withOffset(CGVector(dx: x, dy: toY))
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    /// Scrolls until `element` is not merely present in the accessibility tree
    /// but clear of the bars drawn over the scrolling content, so that `tap()`
    /// — which aims at the element's centre — actually reaches it.
    ///
    /// `scrollTo` stops at existence. On a 375x667 screen that leaves the
    /// Albumin row at y=611 while the tab bar starts at y=618: the tab bar
    /// swallows the touch, the field never takes focus, and the following
    /// `typeText` fails with "Neither element nor any descendant has keyboard
    /// focus".
    private func scrollIntoTappableArea(
        _ element: XCUIElement,
        in app: XCUIApplication,
        maxSwipes: Int = 40
    ) {
        scrollTo(element, in: app, maxSwipes: maxSwipes)
        var swipes = 0
        while element.exists && swipes < maxSwipes {
            let bounds = unobstructedBounds(in: app)
            let frame = element.frame
            if frame.minY >= bounds.top && frame.maxY <= bounds.bottom {
                return
            }
            let span = bounds.bottom - bounds.top
            let near = bounds.top + span * 0.35
            let far = bounds.top + span * 0.75
            if frame.maxY > bounds.bottom {
                dragForm(in: app, fromY: far, toY: near)
            } else {
                dragForm(in: app, fromY: near, toY: far)
            }
            swipes += 1
        }
    }

    /// Fills every required entry, including the sex question, which has no
    /// default and must be answered before a prediction is possible.
    ///
    /// Answers run in form order. The scroll helpers only ever search
    /// downwards, so reaching sex — which sits just below age — after the
    /// albumin field near the bottom would cost 40 fruitless swipes.
    private func fillRequiredFields(in app: XCUIApplication) {
        fillNumberField("Age years", with: enteredAge, in: app)
        selectSex("Male", in: app)
        fillNumberField("Height cm", with: "160", in: app)
        fillNumberField("Weight kg", with: "55", in: app)
        fillNumberField("Albumin g/dL", with: "4", in: app)
    }

    /// Selects one segment of the Sex segmented control.
    private func selectSex(_ option: String, in app: XCUIApplication) {
        let segment = app.buttons[option]
        scrollIntoTappableArea(segment, in: app)
        XCTAssertTrue(segment.waitForExistence(timeout: 5), "Missing sex option: \(option)")
        segment.tap()
    }

    /// Enters only age for reset behavior checks that do not need valid risk data.
    private func fillAgeField(in app: XCUIApplication) {
        fillNumberField("Age years", with: enteredAge, in: app)
    }

    private func fillNumberField(
        _ placeholder: String,
        with value: String,
        in app: XCUIApplication
    ) {
        let field = app.textFields[placeholder]
        scrollIntoTappableArea(field, in: app)
        XCTAssertTrue(field.waitForExistence(timeout: 5), "Missing field: \(placeholder)")
        field.tap()

        // A `TextField(value:format:)` rewrites its own text every time the
        // bound number reparses, and on iOS 16 a keystroke that arrives during
        // that rewrite is swallowed — typing "70" in one go intermittently
        // leaves "7" behind. Enter one character at a time and wait for the
        // field to report it before sending the next.
        var typed = ""
        for character in value {
            typed.append(character)
            var attempts = 0
            while (field.value as? String) != typed && attempts < 3 {
                field.typeText(String(character))
                let accepted = XCTNSPredicateExpectation(
                    predicate: NSPredicate(format: "value == %@", typed),
                    object: field
                )
                _ = XCTWaiter().wait(for: [accepted], timeout: 2)
                attempts += 1
            }
            XCTAssertEqual(field.value as? String, typed,
                           "\(placeholder) did not accept the typed value")
        }

        let dismissKeyboard = app.buttons["dismissKeyboard"]
        XCTAssertTrue(
            dismissKeyboard.waitForExistence(timeout: 5),
            "Keyboard dismiss button is missing"
        )
        XCTAssertEqual(
            dismissKeyboard.label,
            "Dismiss Keyboard",
            "Keyboard dismiss button must expose the English VoiceOver label"
        )
        dismissKeyboard.tap()
    }

    /// Sets an inline Bool question row's Toggle to the desired Yes/No state.
    ///
    /// SwiftUI's Toggle is exposed to XCUITest as `app.switches`, and its
    /// accessibility label is the concatenation of the row's title and
    /// footer text (e.g. "Infrapopliteal Infrapopliteal present or absent"),
    /// so we match with `BEGINSWITH` rather than an exact label.
    private func setToggle(row title: String, to option: String, in app: XCUIApplication) {
        let desiredOn = option == "Yes"
        let row = app.switches
            .matching(NSPredicate(format: "label BEGINSWITH %@", title))
            .firstMatch
        scrollIntoTappableArea(row, in: app)
        XCTAssertTrue(row.waitForExistence(timeout: 5), "Missing toggle row: \(title)")
        // Some runtimes expose a nested unlabeled switch, while iOS 26
        // exposes the labeled row itself as the interactive switch.
        let nestedToggle = row.switches.firstMatch
        let toggle = nestedToggle.exists ? nestedToggle : row
        let isOn = (toggle.value as? String) == "1"
        if isOn != desiredOn {
            toggle.tap()
        }
        let expectedValue = desiredOn ? "1" : "0"
        let stateChanged = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", expectedValue),
            object: toggle
        )
        _ = XCTWaiter().wait(for: [stateChanged], timeout: 5)
        XCTAssertEqual(toggle.value as? String, expectedValue,
                       "Toggle row did not change to the requested value: \(title)")
    }

    /// Scrolls back towards the top of the list in small increments until the
    /// element is on screen and tappable. Mirror image of scrollTo().
    private func scrollToTop(until element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 40) {
        var swipes = 0
        while !(element.exists && element.isHittable) && swipes < maxSwipes {
            dragContent(in: app, from: 0.3, to: 0.45)
            swipes += 1
        }
    }

    /// Uses the application window rather than a queried Table/List. SwiftUI
    /// can replace a scroll container during layout updates; retaining that
    /// container query until the drag causes XCTest's snapshot lookup to fail.
    ///
    /// dx: 0.5 keeps the gesture centred in the form column on both iPhone
    /// (full width) and iPad (where the right half of the content area is the
    /// risk-preview pane and a higher x would land there instead).
    private func dragContent(in app: XCUIApplication, from startY: CGFloat, to endY: CGFloat) {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: startY))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: endY))
        start.press(forDuration: 0.05, thenDragTo: end)
    }

    private func scrollDownTo(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 12) {
        var swipes = 0
        // iOS 26: isHittable is unreliable — stop on existence alone.
        while !element.exists && swipes < maxSwipes {
            let container = patientFormContainer(in: app)
            let start = container.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
            let end   = container.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
            start.press(forDuration: 0.05, thenDragTo: end)
            swipes += 1
        }
    }

    private func scrollUpTo(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 12) {
        var swipes = 0
        // The value assertion after this helper does not require the field to
        // be tappable. On iOS 26, asking hit-testing for an off-screen text
        // field can itself fail when its activation point is not materialized.
        while !element.exists && swipes < maxSwipes {
            let container = patientFormContainer(in: app)
            let start = container.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
            let end   = container.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
            start.press(forDuration: 0.05, thenDragTo: end)
            swipes += 1
        }
    }

    /// Returns the scroll container that holds the patient-data form.
    ///
    /// On iPad the app shows a sidebar next to the form, so we cannot rely on
    /// "the first table/collectionView". Instead, the List in ContentView has
    /// the accessibility identifier "patientDataList" which is stable and unique.
    ///
    /// Re-querying each call avoids stale XCUIElement references when SwiftUI
    /// replaces the underlying collection view during a layout update.
    private func patientFormContainer(in app: XCUIApplication) -> XCUIElement {
        // iOS 16+ renders SwiftUI List as UICollectionView; older builds use UITableView.
        let byIdentifier = app.descendants(matching: .any)
            .matching(identifier: "patientDataList")
            .firstMatch
        if byIdentifier.exists { return byIdentifier }
        return app
    }

    /// Returns the Cancel button of the reset confirmation dialog, probing
    /// sheet, alert, and flat button hierarchies so tests remain stable across
    /// iOS versions that expose the dialog differently.
    private func cancelConfirmationButton(in app: XCUIApplication) -> XCUIElement {
        let sheetButton = app.sheets.buttons["Cancel"]
        if sheetButton.exists { return sheetButton }
        let alertButton = app.alerts.buttons["Cancel"]
        if alertButton.exists { return alertButton }
        return app.buttons.matching(NSPredicate(format: "label == %@", "Cancel")).firstMatch
    }

    private func resetConfirmationButton(in app: XCUIApplication) -> XCUIElement {
        let sheetButton = app.sheets.buttons["Reset data"]
        if sheetButton.exists {
            return sheetButton
        }

        let alertButton = app.alerts.buttons["Reset data"]
        if alertButton.exists {
            return alertButton
        }

        // If XCTest flattens the dialog into the app hierarchy, the first
        // button is the original action and the last one is the dialog action.
        let buttons = app.buttons.matching(identifier: "Reset data")
        return buttons.element(boundBy: max(buttons.count - 1, 0))
    }

    /// Scrolls to the Predict button at the bottom of the form and taps it.
    private func tapPredictButton(in app: XCUIApplication) {
        let predict = app.buttons["predictRisks"]
        scrollIntoTappableArea(predict, in: app)
        XCTAssertTrue(predict.waitForExistence(timeout: 5), "Predict button missing")
        predict.tap()
    }

}
