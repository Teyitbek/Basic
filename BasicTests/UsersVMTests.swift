import XCTest
@testable import Basic

// MARK: - UsersVM tests
//
// TESTING ASYNCHRONOUS CODE
//
// `load(using:)` is an `async` function: it starts, waits for the network,
// and finishes later. A test marked `async` can simply `await` it — the test
// pauses until the work is done, then carries on. No callbacks, no timeouts,
// no waiting helpers.
//
// The repository is a FAKE (see MockRepositories.swift). The real one calls
// jsonplaceholder.typicode.com, which would make this test slow, dependent on
// Wi-Fi, and unable to check what happens when the server fails.

final class UsersVMTests: XCTestCase {

    private var repository: MockUsersRepository!
    private var sut: UsersVM!

    override func setUp() {
        super.setUp()
        repository = MockUsersRepository()
        sut = UsersVM()
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_initially_usersIsEmpty() {
        // Nothing has been loaded yet, so the list must have no rows.
        XCTAssertTrue(sut.users.isEmpty)
    }

    func test_load_onSuccess_storesTheUsers() async {
        // GIVEN a repository that will "return" two users
        repository.getUsersResult = .success([
            Fixtures.user(id: 1, name: "Leanne Graham"),
            Fixtures.user(id: 2, name: "Ervin Howell")
        ])

        // WHEN we ask for them
        await sut.load(using: repository)

        // THEN the view model holds them, ready for the list
        XCTAssertEqual(sut.users.count, 2)
        XCTAssertEqual(sut.users.first?.name, "Leanne Graham")
        XCTAssertTrue(repository.getUsersWasCalled)
    }

    func test_load_onFailure_reportsAnErrorAndKeepsUsersEmpty() async {
        // GIVEN a repository that will fail. This is exactly why we use a
        // mock: making the real network fail on demand would be impossible.
        repository.getUsersResult = .failure(TestError())

        await sut.load(using: repository)

        // THEN an error is available for the view and no stale data was kept
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.users.isEmpty)
    }

    func test_load_whenCalledAgain_doesNotRefetch() async {
        // SwiftUI runs `.task` again whenever the view reappears. Without a
        // guard the list would be re-fetched every time the user navigates
        // back to it.
        repository.getUsersResult = .success([Fixtures.user()])
        await sut.load(using: repository)

        repository.getUsersResult = .success([Fixtures.user(), Fixtures.user()])
        await sut.load(using: repository)

        XCTAssertEqual(sut.users.count, 1)
    }

    func test_whileLoading_isLoadingIsFalseAgainAfterwards() async {
        // The flag drives the spinner, so it must always be switched back off
        // — including when the request fails.
        repository.getUsersResult = .failure(TestError())

        await sut.load(using: repository)

        XCTAssertFalse(sut.isLoading)
    }
}
