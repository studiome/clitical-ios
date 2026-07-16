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

        // Four tabs from the former hamburger menu, starting in Japanese.
        let jaTabs = ["リスク計算", "言語", "参考文献", "アプリ情報"]
        for label in jaTabs {
            XCTAssertTrue(app.tabBars.buttons[label].waitForExistence(timeout: 5),
                          "Missing tab: \(label)")
        }

        // Open the Language tab and choose English.
        app.tabBars.buttons["言語"].tap()
        let englishOption = app.buttons["English"].firstMatch
        XCTAssertTrue(englishOption.waitForExistence(timeout: 5), "English option not found")
        englishOption.tap()

        // The whole UI (including the tab bar) should now be English.
        XCTAssertTrue(app.tabBars.buttons["Risk Assessment"].waitForExistence(timeout: 5),
                      "UI did not switch to English live")
        XCTAssertTrue(app.tabBars.buttons["References"].exists)
        XCTAssertFalse(app.tabBars.buttons["リスク計算"].exists)
    }

    /// Verifies the References and About tabs render their content and links.
    func testReferencesAndAboutTabsRenderContent() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "en"]
        app.launch()

        app.tabBars.buttons["References"].tap()
        XCTAssertTrue(app.staticTexts["Tap to open link."].waitForExistence(timeout: 5))
        let citation = app.descendants(matching: .any)
            .containing(NSPredicate(format: "label BEGINSWITH %@", "1. Miyata")).firstMatch
        XCTAssertTrue(citation.waitForExistence(timeout: 5), "Reference citation missing")

        app.tabBars.buttons["About"].tap()
        XCTAssertTrue(app.staticTexts["CLiTICAL"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Terms of service"].exists
                      || app.links["Terms of service"].exists,
                      "Terms of service link missing")
    }

    /// Tapping a reference citation opens SFSafariViewController inside the app.
    func testReferencesTabOpensInAppBrowser() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "en"]
        app.launch()

        app.tabBars.buttons["References"].tap()

        let citation = app.buttons
            .matching(NSPredicate(format: "label BEGINSWITH %@", "1. Miyata"))
            .firstMatch
        XCTAssertTrue(citation.waitForExistence(timeout: 5), "Reference citation button not found")
        citation.tap()

        // SFSafariViewController shows a Done button when presented as a sheet.
        let done = app.buttons["Done"]
        XCTAssertTrue(done.waitForExistence(timeout: 10), "In-app browser did not open")
        done.tap()

        XCTAssertTrue(app.navigationBars["References"].waitForExistence(timeout: 5),
                      "References view did not reappear after closing the browser")
    }

    /// Tapping the Terms of service button in the About tab opens SFSafariViewController.
    func testAboutTabTermsOpensInAppBrowser() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "en"]
        app.launch()

        app.tabBars.buttons["About"].tap()

        let terms = app.buttons["Terms of service"]
        XCTAssertTrue(terms.waitForExistence(timeout: 5), "Terms of service button not found")
        terms.tap()

        // SFSafariViewController shows a Done button when presented as a sheet.
        let done = app.buttons["Done"]
        XCTAssertTrue(done.waitForExistence(timeout: 10), "In-app browser did not open")
        done.tap()

        XCTAssertTrue(app.navigationBars["About"].waitForExistence(timeout: 5),
                      "About view did not reappear after closing the browser")
    }

    /// Smoke test that the risk-calculation tab's form is interactive inside the
    /// TabView: predicting with an empty form surfaces the validation alert.
    func testRiskCalculationTabPredictShowsValidationAlert() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "en"]
        app.launch()

        app.tabBars.buttons["Risk Assessment"].tap()
        // The Predict button sits at the bottom of a long scrolling form.
        let predict = app.buttons["Predict Risk ..."]
        var swipes = 0
        while !predict.exists && swipes < 12 {
            app.swipeUp()
            swipes += 1
        }
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
        setChoice(row: "Infrapopliteal", to: "Yes", in: app)

        tapPredictButton(in: app)

        XCTAssertTrue(app.navigationBars["Predicted Risks"].waitForExistence(timeout: 5),
                      "Predicted risk screen did not appear")
        XCTAssertTrue(app.staticTexts["Predicted 2-year Overall Survival"].exists)
        // The GNRI section sits at the bottom of the results List; on short
        // screens (e.g. iPhone SE) SwiftUI doesn't materialize it until it's
        // scrolled into view, so it's absent from the accessibility tree
        // until then.
        let gnriTitle = app.staticTexts["Geriatric Nutritional Risk Index"]
        scrollTo(gnriTitle, in: app)
        XCTAssertTrue(gnriTitle.waitForExistence(timeout: 5))
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
        XCTAssertTrue(alert.staticTexts["Check artery lesion. At least 1 lesion should be YES"].exists,
                      "Alert should explain that at least one lesion is required")
        XCTAssertFalse(app.navigationBars["Predicted Risks"].exists)
    }

    // MARK: - Helpers

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
            let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.7))
            let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.55))
            start.press(forDuration: 0.05, thenDragTo: end)
            swipes += 1
        }
    }

    /// Enters age, height, weight, and albumin, then dismisses the keyboard.
    private func fillRequiredNumberFields(in app: XCUIApplication) {
        let values = [
            ("Enter Age [year-old].", "70"),
            ("Enter Body Height [cm].", "160"),
            ("Enter Body Weight [kg].", "55"),
            ("Enter Albumin [g/dl].", "4"),
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
        // After the last field, the keyboard dismiss animation can still be in
        // progress. Without this wait, scrollTo() sees isHittable==false on the
        // Predict button (keyboard covers it) and over-scrolls past it.
        let keyboard = app.keyboards.firstMatch
        if keyboard.exists {
            let keyboardGone = XCTNSPredicateExpectation(
                predicate: NSPredicate(format: "exists == false"),
                object: keyboard
            )
            _ = XCTWaiter().wait(for: [keyboardGone], timeout: 3)
        }
    }

    /// Opens a question row, picks an option on the pushed screen, and goes back.
    private func setChoice(row title: String, to option: String, in app: XCUIApplication) {
        // A list row is exposed as a button labelled "<title>, <current selection>".
        let row = app.buttons
            .matching(NSPredicate(format: "label BEGINSWITH %@", title))
            .firstMatch
        scrollTo(row, in: app)
        XCTAssertTrue(row.waitForExistence(timeout: 5), "Missing question row: \(title)")
        row.tap()

        XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5),
                      "Choice screen for \(title) did not open")
        let optionElement = app.descendants(matching: .any)
            .matching(NSPredicate(format: "label == %@", option))
            .firstMatch
        XCTAssertTrue(optionElement.waitForExistence(timeout: 5),
                      "Missing option \(option) for \(title)")
        optionElement.tap()
        app.navigationBars.buttons.firstMatch.tap()
        // Wait for the pop animation to fully complete before returning.
        // Without this, tapPredictButton's scrollTo runs while the ChoiceListView
        // is still animating out: it burns all 12 swipes on an unstable tree,
        // over-scrolls past the Predict button, and leaves SwiftUI's NavigationView
        // in a state where the programmatic isActive NavigationLink won't fire.
        let dismissed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: app.navigationBars[title]
        )
        _ = XCTWaiter().wait(for: [dismissed], timeout: 5)
    }

    /// Scrolls to the Predict button at the bottom of the form and taps it.
    private func tapPredictButton(in app: XCUIApplication) {
        let predict = app.buttons["Predict Risk ..."]
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
