import XCTest
@testable import Basic

// MARK: - LoginVM tests
//
// HOW A TEST FILE WORKS
//
// 1. The class inherits from `XCTestCase`. Xcode finds every such class.
// 2. Every method whose name starts with `test` is one test. Xcode runs
//    them one by one, each on a FRESH instance of this class, so tests
//    can never affect each other.
// 3. Inside a test you call an `XCTAssert...` function. If the condition
//    holds, the test passes. If not, it fails and Xcode shows you the line.
//
// Run them all with Cmd+U. Run a single one by clicking the diamond in
// the gutter next to it.

final class LoginVMTests: XCTestCase {

    // `sut` = "system under test". A very common name in tests: it makes
    // it obvious which object the file is about.
    private var sut: LoginVM!

    // `setUp` runs BEFORE each test. Use it to build a clean object so no
    // test inherits leftovers from a previous one.
    override func setUp() {
        super.setUp()
        sut = LoginVM()
    }

    // `tearDown` runs AFTER each test. Releasing the object here keeps
    // memory clean and surfaces retain-cycle bugs early.
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    /// Fills the form the way the user would by typing into the fields. The
    /// view model owns the text, so the SwiftUI view binds straight to it.
    private func fillForm(name: String = "Teyit",
                          email: String = "teyit@example.com",
                          password: String = "secret123") {
        sut.name = name
        sut.email = email
        sut.password = password
    }

    // MARK: - Name

    func test_login_withEmptyName_showsRequiredError() {
        // Most tests follow three steps, often called Given / When / Then:

        // GIVEN — the starting situation
        fillForm(name: "")

        // WHEN — the thing we are testing happens
        sut.login()

        // THEN — check the result is what we expect
        XCTAssertEqual(sut.nameError, "Name is required")
    }

    func test_login_withWhitespaceOnlyName_showsRequiredError() {
        // The view model trims spaces, so "   " should count as empty.
        fillForm(name: "   ")

        sut.login()

        XCTAssertEqual(sut.nameError, "Name is required")
    }

    func test_login_withOneLetterName_showsTooShortError() {
        fillForm(name: "T")

        sut.login()

        XCTAssertEqual(sut.nameError, "Name must be at least 2 characters")
    }

    func test_login_withValidName_showsNoNameError() {
        fillForm()

        sut.login()

        // No error means the value is nil.
        XCTAssertNil(sut.nameError)
    }

    // MARK: - Email

    func test_login_withEmptyEmail_showsRequiredError() {
        fillForm(email: "")

        sut.login()

        XCTAssertEqual(sut.emailError, "Email is required")
    }

    func test_login_withMalformedEmails_showsInvalidError() {
        // Rather than writing one test per bad email, we loop over a list.
        let badEmails = ["teyit", "teyit@", "@example.com", "teyit@example", "teyit example.com"]

        for email in badEmails {
            fillForm(email: email)

            sut.login()

            // The `email` value is put in the failure message, so when this
            // fails you immediately know WHICH of the five inputs broke it.
            XCTAssertEqual(sut.emailError, "Enter a valid email", "failed for: \(email)")
        }
    }

    func test_login_withValidEmail_showsNoEmailError() {
        fillForm(email: "teyit.a@example.co.uk")

        sut.login()

        XCTAssertNil(sut.emailError)
    }

    // MARK: - Password

    func test_login_withEmptyPassword_showsRequiredError() {
        fillForm(password: "")

        sut.login()

        XCTAssertEqual(sut.passwordError, "Password is required")
    }

    func test_login_withShortPassword_showsTooShortError() {
        fillForm(password: "ab1")

        sut.login()

        XCTAssertEqual(sut.passwordError, "Password must be at least 6 characters")
    }

    func test_login_withLettersOnlyPassword_showsMissingNumberError() {
        fillForm(password: "abcdefg")

        sut.login()

        XCTAssertEqual(sut.passwordError, "Password must contain a letter and a number")
    }

    func test_login_withDigitsOnlyPassword_showsMissingLetterError() {
        fillForm(password: "1234567")

        sut.login()

        XCTAssertEqual(sut.passwordError, "Password must contain a letter and a number")
    }

    func test_login_withValidPassword_showsNoPasswordError() {
        fillForm()

        sut.login()

        XCTAssertNil(sut.passwordError)
    }

    // MARK: - The decision
    //
    // These are the most important tests in this file: they check what the
    // screen actually decides — do we let the user in or not? The view calls
    // `onLoginSuccess()` only when `login()` returns true.

    func test_login_withValidInput_isAllowed() {
        fillForm()

        XCTAssertTrue(sut.login())
    }

    func test_login_withInvalidInput_isRefused() {
        // Name and email are fine, but the password is too short. One bad
        // field must be enough to block the login.
        fillForm(password: "abc")

        XCTAssertFalse(sut.login())
    }

    func test_login_afterFixingInput_clearsPreviousErrors() {
        // A real user gets it wrong, then corrects it. The old error message
        // must disappear — otherwise the screen keeps showing red.

        // GIVEN a failed attempt
        fillForm(name: "", email: "nope", password: "abc")
        sut.login()
        XCTAssertNotNil(sut.nameError)

        // WHEN the user fixes everything and tries again
        fillForm()
        sut.login()

        // THEN every error is cleared
        XCTAssertNil(sut.nameError)
        XCTAssertNil(sut.emailError)
        XCTAssertNil(sut.passwordError)
    }
}
