//
//  cliticalUITests.swift
//  cliticalUITests
//
//  Created by kmiyahara on 2022/12/20.
//

import XCTest

final class cliticalUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Verifies the bottom tab menu exists and that selecting English in the
    /// Language tab re-localizes the whole UI live (no relaunch).
    func testLanguageTabSwitchesLocaleLive() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "ja"]
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

    /// Happy path: filling every required field and marking one artery lesion
    /// pushes the predicted-risk screen with the 2-year and GNRI results.
    func testPredictWithValidDataShowsRiskResults() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "en"]
        app.launch()

        fillRequiredNumberFields(in: app)
        setToggle(row: "Infrapopliteal", to: "Yes", in: app)

        tapPredictButton(in: app)

        XCTAssertTrue(app.navigationBars["Predicted Risks"].waitForExistence(timeout: 5),
                      "Predicted risk screen did not appear")
        // In landscape the list viewport is shorter, so both the 2-year and
        // GNRI sections may be off-screen until scrolled into view.
        let twoYearTitle = app.staticTexts["Predicted 2-year Overall Survival"]
        scrollTo(twoYearTitle, in: app)
        XCTAssertTrue(twoYearTitle.waitForExistence(timeout: 5),
                      "Predicted 2-year Overall Survival did not appear")
        let gnriTitle = app.staticTexts["Geriatric Nutritional Risk Index"]
        scrollTo(gnriTitle, in: app)
        XCTAssertTrue(gnriTitle.waitForExistence(timeout: 5),
                      "Geriatric Nutritional Risk Index did not appear")
    }

    /// The urgency question is two independent named states (urgent vs.
    /// elective revascularization), not an on/off mechanism, so per HIG it
    /// must be an inline segmented control with both options visibly
    /// labeled — matching the pattern already used for Sex.
    func testUrgencyQuestionIsSegmentedControlWithBothLabels() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "en"]
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
        app.launch()

        fillRequiredNumberFields(in: app)
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
        app.launch()

        fillAgeField(in: app)

        let reset = app.buttons["Reset data"]
        scrollDownTo(reset, in: app)
        XCTAssertTrue(reset.waitForExistence(timeout: 5), "Reset button missing")
        reset.tap()

        // Dismissing the confirmation without confirming must keep the data.
        // On this OS the dialog presents as a popover, where the cancel-role
        // button is omitted and tapping outside dismisses (per HIG).
        let dialog = app.sheets.firstMatch
        XCTAssertTrue(dialog.waitForExistence(timeout: 5),
                      "Reset confirmation dialog did not appear")
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.15)).tap()
        let dialogGone = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: dialog
        )
        _ = XCTWaiter().wait(for: [dialogGone], timeout: 5)

        let ageField = app.textFields["Age [year-old]"]
        scrollUpTo(ageField, in: app)
        XCTAssertEqual(ageField.value as? String, "70",
                       "Dismissing the confirmation must not clear the data")

        // Confirming must clear the data (the placeholder shows again).
        scrollDownTo(reset, in: app)
        reset.tap()
        XCTAssertTrue(dialog.waitForExistence(timeout: 5),
                      "Reset confirmation dialog did not appear")
        dialog.buttons["Reset data"].tap()

        scrollUpTo(ageField, in: app)
        XCTAssertEqual((ageField.value as? String) ?? "", "",
                       "Confirming the dialog must clear the data")
    }

    // MARK: - Helpers

    private func topLevelItem(_ label: String, in app: XCUIApplication) -> XCUIElement {
        let tabButton = app.tabBars.buttons[label]
        if tabButton.exists {
            return tabButton
        }
        return app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@", label))
            .firstMatch
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

    /// Scrolls up in small increments until the element is on screen and
    /// tappable.
    ///
    /// app.swipeUp() drags nearly the full screen height in one gesture. On
    /// a short screen (e.g. iPhone SE) that single jump can skip clean over
    /// a target row's position between the before/after existence checks, so
    /// the loop never observes it as hittable and scrolls all the way to the
    /// bottom of the list. A short, fixed-distance drag lands more precisely
    /// at the cost of needing more iterations, which the higher cap covers.
    private func scrollTo(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 40) {
        var swipes = 0
        while !(element.exists && element.isHittable) && swipes < maxSwipes {
            let container = scrollContainer(in: app)
            let start = container.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
            let end = container.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.55))
            start.press(forDuration: 0.05, thenDragTo: end)
            swipes += 1
        }
    }

    /// Enters age, height, weight, and albumin, then dismisses the keyboard.
    private func fillRequiredNumberFields(in app: XCUIApplication) {
        let values = [
            ("Age [year-old]", "70"),
            ("Body Height [cm]", "160"),
            ("Body Weight [kg]", "55"),
            ("Albumin [g/dl]", "4"),
        ]
        for (placeholder, value) in values {
            let field = app.textFields[placeholder]
            scrollTo(field, in: app)
            XCTAssertTrue(field.waitForExistence(timeout: 5), "Missing field: \(placeholder)")
            field.tap()
            field.typeText(value)
            let done = app.buttons["Done"]
            if done.exists { done.tap() }
        }
    }

    /// Enters only age for reset behavior checks that do not need valid risk data.
    private func fillAgeField(in app: XCUIApplication) {
        let field = app.textFields["Age [year-old]"]
        scrollTo(field, in: app)
        XCTAssertTrue(field.waitForExistence(timeout: 5), "Missing field: Age [year-old]")
        field.tap()
        field.typeText("70")
        let done = app.buttons["Done"]
        if done.exists { done.tap() }
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
        scrollTo(row, in: app)
        XCTAssertTrue(row.waitForExistence(timeout: 5), "Missing toggle row: \(title)")
        // SwiftUI exposes the row as two nested Switch elements: an outer one
        // combining the row's title+footer text as its label, and an inner
        // (unlabelled) one that is the real interactive control backing the
        // accessibility activate action. Tapping the outer element is a
        // no-op, so drill into the inner switch and tap that instead.
        let toggle = row.switches.firstMatch
        let isOn = (toggle.value as? String) == "1"
        if isOn != desiredOn {
            toggle.tap()
        }
    }

    /// Scrolls back towards the top of the list in small increments until the
    /// element is on screen and tappable. Mirror image of scrollTo().
    private func scrollToTop(until element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 40) {
        var swipes = 0
        while !(element.exists && element.isHittable) && swipes < maxSwipes {
            let container = scrollContainer(in: app)
            let start = container.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
            let end = container.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45))
            start.press(forDuration: 0.05, thenDragTo: end)
            swipes += 1
        }
    }

    private func scrollContainer(in app: XCUIApplication) -> XCUIElement {
        for index in 0..<3 {
            let table = app.tables.element(boundBy: index)
            if table.exists,
               table.staticTexts["Basic Information"].exists
                || table.staticTexts["患者基本情報"].exists
                || table.textFields["Age [year-old]"].exists
                || table.textFields["年齢 [歳]"].exists {
                return table
            }
        }
        if app.tables.firstMatch.exists {
            return app.tables.firstMatch
        }
        if app.collectionViews.firstMatch.exists {
            return app.collectionViews.firstMatch
        }
        if app.scrollViews.firstMatch.exists {
            return app.scrollViews.firstMatch
        }
        if app.windows.firstMatch.exists {
            return app.windows.firstMatch
        }
        return app
    }

    private func scrollDownTo(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 12) {
        var swipes = 0
        while !(element.exists && element.isHittable) && swipes < maxSwipes {
            scrollContainer(in: app).swipeUp()
            swipes += 1
        }
    }

    private func scrollUpTo(_ element: XCUIElement, in app: XCUIApplication, maxSwipes: Int = 12) {
        var swipes = 0
        while !(element.exists && element.isHittable) && swipes < maxSwipes {
            scrollContainer(in: app).swipeDown()
            swipes += 1
        }
    }

    /// Scrolls to the Predict button at the bottom of the form and taps it.
    private func tapPredictButton(in app: XCUIApplication) {
        let predict = app.buttons["Predict Risk"]
        scrollTo(predict, in: app)
        XCTAssertTrue(predict.waitForExistence(timeout: 5), "Predict button missing")
        predict.tap()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
