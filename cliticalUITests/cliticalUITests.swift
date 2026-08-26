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

/// What an empty numeric field reports. The fields carry a placeholder so an
/// untouched row reads as an input field rather than as blank space, and
/// XCUITest surfaces that placeholder as the field's value.
let emptyNumberFieldValue = "--"

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
        app.launchArguments += ["-app_language", "en"]
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

    /// Verifies the bottom tab menu exists and that selecting English in the
    /// Language tab re-localizes the whole UI live (no relaunch).
    func testLanguageTabSwitchesLocaleLive() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "ja"]
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        // Three top-level destinations, starting in Japanese. On iPad and
        // newer OSes these may be exposed as sidebar items instead of a
        // bottom tab bar.
        let jaTabs = ["リスク計算", "参考文献", "設定"]
        for label in jaTabs {
            XCTAssertTrue(topLevelItem(label, in: app).waitForExistence(timeout: 5),
                          "Missing tab: \(label)")
        }

        // Open the Settings tab and choose English in the language picker.
        tapTopLevelItem("設定", in: app)
        let englishOption = languageOption("English", in: app)
        XCTAssertTrue(englishOption.waitForExistence(timeout: 5), "English option not found")
        englishOption.tap()

        // The whole UI (including top-level navigation) should now be English.
        XCTAssertTrue(topLevelItem("Risk Assessment", in: app).waitForExistence(timeout: 5),
                      "UI did not switch to English live")
        XCTAssertTrue(topLevelItem("References", in: app).exists)
        XCTAssertTrue(topLevelItem("Settings", in: app).exists)
        XCTAssertFalse(topLevelItem("リスク計算", in: app).exists)

        // Navigation bar titles must also re-localize live, not just tab labels.
        tapTopLevelItem("Risk Assessment", in: app)
        XCTAssertTrue(app.staticTexts["Basic Information"].waitForExistence(timeout: 5),
                      "In-body section header did not switch to English live")
        XCTAssertTrue(app.navigationBars["Patient Data"].waitForExistence(timeout: 5),
                      "Risk calculation nav title did not switch to English live")
        XCTAssertFalse(app.navigationBars["患者データ"].exists)

        // The Sex segmented control's options must also re-localize live,
        // not just tab labels. Sex is now an inline segmented row (no pushed
        // screen), so we assert its segment labels directly.
        let maleOption = app.buttons["Male"]
        scrollTo(maleOption, in: app)
        XCTAssertTrue(maleOption.waitForExistence(timeout: 5),
                      "Sex segmented option did not switch to English live")
        XCTAssertTrue(app.buttons["Female"].exists, "Female segmented option missing")

        tapTopLevelItem("References", in: app)
        XCTAssertTrue(app.navigationBars["References"].waitForExistence(timeout: 5),
                      "References nav title did not switch to English live")

        tapTopLevelItem("Settings", in: app)
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5),
                      "Settings nav title did not switch to English live")
    }

    /// Verifies the References and Settings tabs render their content and links.
    func testReferencesAndSettingsTabsRenderContent() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "en"]
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        tapTopLevelItem("References", in: app)
        XCTAssertTrue(app.staticTexts["Tap to open link."].waitForExistence(timeout: 5))
        let citation = app.descendants(matching: .any)
            .containing(NSPredicate(format: "label BEGINSWITH %@", "1. Miyata")).firstMatch
        XCTAssertTrue(citation.waitForExistence(timeout: 5), "Reference citation missing")

        tapTopLevelItem("Settings", in: app)
        let englishButton = languageOption("English", in: app)
        scrollTo(englishButton, in: app)
        XCTAssertTrue(englishButton.waitForExistence(timeout: 5),
                      "Language picker missing from Settings")
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
        app.launchArguments += ["-app_language", "en"]
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        fillAgeField(in: app)
        tapTopLevelItem("References", in: app)
        XCTAssertTrue(app.staticTexts["Tap to open link."].waitForExistence(timeout: 5))

        tapTopLevelItem("Risk Assessment", in: app)
        let ageField = app.textFields["Age [years]"]
        scrollUpTo(ageField, in: app)
        XCTAssertEqual(ageField.value as? String, "70",
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
        app.launchArguments += ["-app_language", "en"]
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        tapTopLevelItem("Risk Assessment", in: app)
        // The Predict button sits at the bottom of a long scrolling form.
        let predict = app.buttons["Predict Risk"]
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
            "-app_language", "en",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL",
        ]
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        for label in ["Age [years]", "Body Height [cm]", "Body Weight [kg]", "Albumin [g/dL]"] {
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
        app.launchArguments += ["-app_language", "en"]
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        tapPredictButton(in: app)

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Validation alert did not appear")
        XCTAssertTrue(
            alert.staticTexts["Enter a value for Age [years]."].exists,
            "The alert should name the first field that needs attention"
        )
    }

    /// Validation walks the form from the top, so the question after age is
    /// sex — which has no default and must be answered explicitly.
    func testPredictWithOnlyAgeNamesSexAsNextMissingAnswer() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "en"]
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
        app.launchArguments += ["-app_language", "en"]
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        fillAgeField(in: app)
        selectSex("Male", in: app)
        tapPredictButton(in: app)

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Validation alert did not appear")
        XCTAssertTrue(
            alert.staticTexts["Enter a value for Body Height [cm]."].exists,
            "The alert should name the next missing field"
        )
    }

    /// The regression this whole range check exists for: a height typed in
    /// metres used to produce a plausible looking risk instead of an error.
    func testHeightEnteredInMetresIsRejected() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "en"]
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        fillAgeField(in: app)
        selectSex("Male", in: app)
        fillNumberField("Body Height [cm]", with: "1.7", in: app)
        fillNumberField("Body Weight [kg]", with: "60", in: app)
        fillNumberField("Albumin [g/dL]", with: "3.5", in: app)
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
        app.launchArguments += ["-app_language", "en"]
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
        app.launchArguments += ["-app_language", "en"]
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
        app.launchArguments += ["-app_language", "en"]
        app.launchArguments += acknowledgedDisclaimerArguments
        app.launch()

        tapTopLevelItem("Risk Assessment", in: app)

        let urgent = app.buttons["Urgent"]
        scrollTo(urgent, in: app)
        XCTAssertTrue(urgent.waitForExistence(timeout: 5),
                      "Urgency segmented option 'Urgent' missing")
        XCTAssertTrue(app.buttons["Elective"].exists,
                      "Urgency segmented option 'Elective' missing")
    }

    /// With valid numbers but no artery lesion selected, predicting must show
    /// the lesion-specific validation alert instead of the risk screen.
    func testPredictWithoutLesionShowsLesionAlert() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "en"]
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

    /// Reset is destructive, so it must ask for confirmation first: cancelling
    /// keeps the entered data, confirming clears it.
    func testResetAsksForConfirmationBeforeClearingData() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "en"]
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

        let ageField = app.textFields["Age [years]"]
        scrollUpTo(ageField, in: app)
        XCTAssertEqual(ageField.value as? String, "70",
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
        XCTAssertEqual(ageField.value as? String, emptyNumberFieldValue,
                       "Confirming the dialog must clear the data")
    }

    // MARK: - Helpers

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

    /// On iOS 16, an inline SwiftUI Picker is exposed as switches; later
    /// runtimes expose the same options as buttons. Select the control type
    /// that is present so the test asserts the same user-visible choice.
    private func languageOption(_ label: String, in app: XCUIApplication) -> XCUIElement {
        let toggle = app.switches[label]
        return toggle.exists ? toggle : app.buttons[label]
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
        fillNumberField("Age [years]", with: "70", in: app)
        selectSex("Male", in: app)
        fillNumberField("Body Height [cm]", with: "160", in: app)
        fillNumberField("Body Weight [kg]", with: "55", in: app)
        fillNumberField("Albumin [g/dL]", with: "4", in: app)
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
        fillNumberField("Age [years]", with: "70", in: app)
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
        let predict = app.buttons["Predict Risk"]
        scrollIntoTappableArea(predict, in: app)
        XCTAssertTrue(predict.waitForExistence(timeout: 5), "Predict button missing")
        predict.tap()
    }

}
