import XCTest
import Combine
@testable import ToDoTabbar

// MARK: - UsersVM tests
//
// TESTING ASYNCHRONOUS CODE
//
// `getUsers()` does not finish immediately: it starts a `Task`, and only
// later publishes on `successGetUsers`. If the test just called the method
// and checked the result on the next line, the work would not have happened
// yet and the test would fail for the wrong reason.
//
// The fix is `XCTestExpectation`:
//   1. create an expectation  — "something should happen"
//   2. fulfill it in the callback — "it happened"
//   3. `wait(for:timeout:)`   — pause the test until it does (or give up)

final class UsersVMTests: XCTestCase {
    
    private var repository: MockUsersRepository!
    private var sut: UsersVM!
    /// Combine subscriptions must be kept alive, or they are cancelled
    /// immediately and the callbacks never run.
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        repository = MockUsersRepository()
        sut = UsersVM(services: .mocked(users: repository))
        bag = []
    }
    
    override func tearDown() {
        bag = nil
        sut = nil
        repository = nil
        super.tearDown()
    }
    
    func test_initially_usersIsEmpty() {
        // Nothing has been loaded yet, so the table must have no rows.
        XCTAssertTrue(sut.users.isEmpty)
    }
    
    func test_getUsers_onSuccess_storesTheUsers() {
        // GIVEN a repository that will "return" two users
        repository.getUsersResult = .success([
            Fixtures.user(id: 1, name: "Leanne Graham"),
            Fixtures.user(id: 2, name: "Ervin Howell")
        ])
        
        let expectation = expectation(description: "successGetUsers is published")
        sut.successGetUsers
            .sink { _ in expectation.fulfill() }
            .store(in: &bag)
        
        // WHEN we ask for the users
        sut.getUsers()
        
        // Pause here until the expectation is fulfilled. If 1 second passes
        // without that happening, the test fails with a timeout.
        wait(for: [expectation], timeout: 1)
        
        // THEN the view model holds them, ready for the table view
        XCTAssertEqual(sut.users.count, 2)
        XCTAssertEqual(sut.users.first?.name, "Leanne Graham")
        XCTAssertTrue(repository.getUsersWasCalled)
    }
    
    func test_getUsers_onFailure_publishesAnErrorAndKeepsUsersEmpty() {
        // GIVEN a repository that will fail.
        // This is exactly why we use a mock: making the real network fail
        // on demand would be impossible.
        repository.getUsersResult = .failure(TestError())
        
        let expectation = expectation(description: "errorMessage is published")
        var receivedMessage: String?
        sut.errorMessage
            .sink { message in
                receivedMessage = message
                expectation.fulfill()
            }
            .store(in: &bag)
        
        // WHEN we ask for the users
        sut.getUsers()
        
        wait(for: [expectation], timeout: 1)
        
        // THEN an error was reported and no stale data was kept
        XCTAssertNotNil(receivedMessage)
        XCTAssertTrue(sut.users.isEmpty)
    }
}
