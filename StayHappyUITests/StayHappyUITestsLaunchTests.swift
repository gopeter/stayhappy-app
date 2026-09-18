//
//  StayHappyUITestsLaunchTests.swift
//  StayHappyUITests
//
//  Created by Peter Oesteritz on 10.01.24.
//

import XCTest

// XCUIApplication is main-actor isolated, so the test methods driving it have
// to be too.
@MainActor
final class StayHappyUITestsLaunchTests: XCTestCase {

    override nonisolated class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
