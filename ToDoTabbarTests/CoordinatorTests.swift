import XCTest
@testable import ToDoTabbar

// MARK: - Coordinator tests
//
// Everything above tests one object on its own. These two tests are a step
// up: they check that the pieces are WIRED TOGETHER correctly — that a
// successful login really does move the user to the tab bar.
//
// We do not need a real screen on a real device for this. A
// `UINavigationController` is just an object holding an array of view
// controllers, so we can create one, let the coordinator drive it, and
// then read that array to see where the user ended up.

final class CoordinatorTests: XCTestCase {
    
    private var navigation: UINavigationController!
    private var sut: Coordinator!
    
    override func setUp() {
        super.setUp()
        navigation = UINavigationController()
        // Mocked services, so nothing here can touch the network.
        let services = Services.mocked()
        sut = Coordinator(navigation: navigation,
                          services: services,
                          factory: Factory(services: services))
    }
    
    override func tearDown() {
        sut = nil
        navigation = nil
        super.tearDown()
    }
    
    func test_start_showsTheLoginScreen() {
        sut.start()
        
        // `is` checks the type of the object that is on screen.
        XCTAssertTrue(navigation.viewControllers.first is LoginVC)
        XCTAssertEqual(navigation.viewControllers.count, 1)
    }
    
    func test_afterAValidLogin_showsTheTabbar() {
        // GIVEN the login screen
        sut.start()
        let loginVC = navigation.viewControllers.first as? LoginVC
        
        // WHEN the user logs in successfully.
        // We drive the view model directly — that is the same thing the
        // button tap does, minus the tapping.
        loginVC?.viewModel.login(name: "Teyit",
                                 email: "teyit@example.com",
                                 password: "secret123")
        
        // THEN the tab bar replaced the login screen.
        // The coordinator swaps the stack *with an animation*, which UIKit
        // applies on the next run loop pass — so we wait for it rather than
        // checking immediately. See `wait(until:)` in WaitHelpers.swift.
        wait(until: { navigation.viewControllers.first is TabbarVC })
        
        // And login is no longer in the stack: the user must not be able to
        // swipe back to it.
        XCTAssertEqual(navigation.viewControllers.count, 1)
    }
    
    func test_afterAnInvalidLogin_staysOnTheLoginScreen() {
        sut.start()
        let loginVC = navigation.viewControllers.first as? LoginVC
        
        // The password is too short, so the login must be refused.
        loginVC?.viewModel.login(name: "Teyit",
                                 email: "teyit@example.com",
                                 password: "abc")
        
        XCTAssertTrue(navigation.viewControllers.first is LoginVC)
    }
}
