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

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    /// Verifies the bottom tab menu exists and that selecting English in the
    /// Language tab re-localizes the whole UI live (no relaunch).
    func testLanguageTabSwitchesLocaleLive() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-app_language", "ja"]
        app.launch()

        // Four tabs from the former hamburger menu, starting in Japanese.
        let jaTabs = ["リスク計算", "言語", "参考文献", "このアプリについて"]
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

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
