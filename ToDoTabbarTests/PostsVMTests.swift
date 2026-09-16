import XCTest
@testable import ToDoTabbar

// MARK: - PostsVM tests
//
// The same shape as UsersVMTests — success path and failure path. Once you
// have seen the pattern once, every list screen tests the same way.

final class PostsVMTests: XCTestCase {

    private var repository: MockPostsRepository!
    private var sut: PostsVM!

    override func setUp() {
        super.setUp()
        repository = MockPostsRepository()
        sut = PostsVM()
    }

    override func tearDown() {
        sut = nil
        repository = nil
        super.tearDown()
    }

    func test_load_onSuccess_storesThePostsInOrder() async {
        repository.getPostsResult = .success([
            Fixtures.post(id: 1, title: "First"),
            Fixtures.post(id: 2, title: "Second")
        ])

        await sut.load(using: repository)

        // The order matters: the list shows them exactly as stored.
        XCTAssertEqual(sut.posts.map { $0.title }, ["First", "Second"])
    }

    func test_load_onFailure_reportsAnError() async {
        repository.getPostsResult = .failure(TestError())

        await sut.load(using: repository)

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.posts.isEmpty)
    }
}
