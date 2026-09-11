import XCTest
import Combine
@testable import ToDoTabbar

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
    
    // `setUp` runs BEFORE each test method. Use it to build a clean object
    // so no test inherits leftovers from a previous one.
    override func setUp() {
        super.setUp()
        sut = LoginVM()
    }
    
    // `tearDown` runs AFTER each test method. Releasing the object here
    // keeps memory clean and surfaces retain-cycle bugs early.
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Name
    
    func test_login_withEmptyName_showsRequiredError() {
        // Most tests follow three steps, often called Given / When / Then:
        
        // GIVEN — the starting situation (here: a fresh LoginVM from setUp)
        
        // WHEN — the thing we are testing happens
        sut.login(name: "", email: "teyit@example.com", password: "secret123")
        
        // THEN — check the result is what we expect.
        // `.value` reads the latest value the subject published.
        XCTAssertEqual(sut.nameError.value, "Name is required")
    }
    
    func test_login_withWhitespaceOnlyName_showsRequiredError() {
        // The view model trims spaces, so "   " should count as empty.
        sut.login(name: "   ", email: "teyit@example.com", password: "secret123")
        
        XCTAssertEqual(sut.nameError.value, "Name is required")
    }
    
    func test_login_withOneLetterName_showsTooShortError() {
        sut.login(name: "T", email: "teyit@example.com", password: "secret123")
        
        XCTAssertEqual(sut.nameError.value, "Name must be at least 2 characters")
    }
    
    func test_login_withValidName_showsNoNameError() {
        sut.login(name: "Teyit", email: "teyit@example.com", password: "secret123")
        
        // No error means the value is nil.
        XCTAssertNil(sut.nameError.value)
    }
    
    // MARK: - Email
    
    func test_login_withEmptyEmail_showsRequiredError() {
        sut.login(name: "Teyit", email: "", password: "secret123")
        
        XCTAssertEqual(sut.emailError.value, "Email is required")
    }
    
    func test_login_withMalformedEmails_showsInvalidError() {
        // Rather than writing one test per bad email, we loop over a list.
        let badEmails = ["teyit", "teyit@", "@example.com", "teyit@example", "teyit example.com"]
        
        for email in badEmails {
            sut.login(name: "Teyit", email: email, password: "secret123")
            
            // The `email` value is put in the failure message, so when this
            // fails you immediately know WHICH of the five inputs broke it.
            XCTAssertEqual(sut.emailError.value, "Enter a valid email", "failed for: \(email)")
        }
    }
    
    func test_login_withValidEmail_showsNoEmailError() {
        sut.login(name: "Teyit", email: "teyit.a@example.co.uk", password: "secret123")
        
        XCTAssertNil(sut.emailError.value)
    }
    
    // MARK: - Password
    
    func test_login_withEmptyPassword_showsRequiredError() {
        sut.login(name: "Teyit", email: "teyit@example.com", password: "")
        
        XCTAssertEqual(sut.passwordError.value, "Password is required")
    }
    
    func test_login_withShortPassword_showsTooShortError() {
        sut.login(name: "Teyit", email: "teyit@example.com", password: "ab1")
        
        XCTAssertEqual(sut.passwordError.value, "Password must be at least 6 characters")
    }
    
    func test_login_withLettersOnlyPassword_showsMissingNumberError() {
        sut.login(name: "Teyit", email: "teyit@example.com", password: "abcdefg")
        
        XCTAssertEqual(sut.passwordError.value, "Password must contain a letter and a number")
    }
    
    func test_login_withDigitsOnlyPassword_showsMissingLetterError() {
        sut.login(name: "Teyit", email: "teyit@example.com", password: "1234567")
        
        XCTAssertEqual(sut.passwordError.value, "Password must contain a letter and a number")
    }
    
    func test_login_withValidPassword_showsNoPasswordError() {
        sut.login(name: "Teyit", email: "teyit@example.com", password: "secret123")
        
        XCTAssertNil(sut.passwordError.value)
    }
    
    // MARK: - Success callback
    //
    // These are the most important tests in this file: they check the
    // decision the screen actually makes — do we let the user in or not?
    
    func test_login_withValidInput_callsOnLoginSuccess() {
        // GIVEN a flag that the callback will flip
        var didSucceed = false
        sut.onLoginSuccess = { didSucceed = true }
        
        // WHEN everything is valid
        sut.login(name: "Teyit", email: "teyit@example.com", password: "secret123")
        
        // THEN the coordinator was told to move on
        XCTAssertTrue(didSucceed)
    }
    
    func test_login_withInvalidInput_doesNotCallOnLoginSuccess() {
        var didSucceed = false
        sut.onLoginSuccess = { didSucceed = true }
        
        // Name and email are fine, but the password is too short.
        // One bad field must be enough to block the login.
        sut.login(name: "Teyit", email: "teyit@example.com", password: "abc")
        
        XCTAssertFalse(didSucceed)
    }
    
    func test_login_afterFixingInput_clearsPreviousErrors() {
        // A real user gets it wrong, then corrects it. The old error
        // message must disappear — otherwise the screen keeps showing red.
        
        // GIVEN a failed attempt
        sut.login(name: "", email: "nope", password: "abc")
        XCTAssertNotNil(sut.nameError.value)
        
        // WHEN the user fixes everything and tries again
        sut.login(name: "Teyit", email: "teyit@example.com", password: "secret123")
        
        // THEN every error is cleared
        XCTAssertNil(sut.nameError.value)
        XCTAssertNil(sut.emailError.value)
        XCTAssertNil(sut.passwordError.value)
    }
}
