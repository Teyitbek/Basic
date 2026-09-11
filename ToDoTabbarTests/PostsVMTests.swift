import XCTest
import Combine
@testable import ToDoTabbar

// MARK: - PostsVM tests
//
// The same shape as UsersVMTests — success path and failure path.
// Once you have seen the pattern once, every list screen tests the same way.

final class PostsVMTests: XCTestCase {
    
    private var repository: MockPostsRepository!
    private var sut: PostsVM!
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        repository = MockPostsRepository()
        sut = PostsVM(services: .mocked(posts: repository))
        bag = []
    }
    
    override func tearDown() {
        bag = nil
        sut = nil
        repository = nil
        super.tearDown()
    }
    
    func test_getPosts_onSuccess_storesThePostsInOrder() {
        repository.getPostsResult = .success([
            Fixtures.post(id: 1, title: "First"),
            Fixtures.post(id: 2, title: "Second")
        ])
        
        let expectation = expectation(description: "successGetPosts is published")
        sut.successGetPosts
            .sink { _ in expectation.fulfill() }
            .store(in: &bag)
        
        sut.getPosts()
        
        wait(for: [expectation], timeout: 1)
        
        // The order matters: the table shows them exactly as stored.
        XCTAssertEqual(sut.posts.map { $0.title }, ["First", "Second"])
    }
    
    func test_getPosts_onFailure_publishesAnError() {
        repository.getPostsResult = .failure(TestError())
        
        let expectation = expectation(description: "errorMessage is published")
        sut.errorMessage
            .sink { _ in expectation.fulfill() }
            .store(in: &bag)
        
        sut.getPosts()
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(sut.posts.isEmpty)
    }
}
