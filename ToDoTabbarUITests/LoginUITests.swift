import XCTest

// MARK: - UI tests
//
// A UNIT test (everything in ToDoTabbarTests) checks one object in memory.
// It runs in milliseconds and never opens the app.
//
// A UI test is different: it launches the real app in the simulator and
// taps around it like a person would. That makes it slower and more
// fragile, so the rule of thumb is:
//
//   * unit tests    — many of them, for logic
//   * UI tests      — a few of them, for "does the app actually start and
//                     show the right first screen"
//
// This file has exactly one such smoke test.

final class LoginUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // If a tap fails, stop immediately: everything after it would fail
        // too, and the first failure is the interesting one.
        continueAfterFailure = false
    }
    
    func test_appLaunches_showingTheLoginScreen() {
        // `XCUIApplication` is a remote control for the app.
        let app = XCUIApplication()
        app.launch()
        
        // `waitForExistence` gives the app a moment to start before checking.
        // Text fields are found by their placeholder text.
        XCTAssertTrue(app.textFields["Name"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.secureTextFields["Password"].exists)
        XCTAssertTrue(app.buttons["Login"].exists)
    }
}
