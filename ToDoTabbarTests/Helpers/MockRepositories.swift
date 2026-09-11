import Foundation
@testable import ToDoTabbar

// MARK: - Mocks
//
// A "mock" (or "fake", or "test double") is a stand-in for a real object.
//
// The real `UsersRepository` calls jsonplaceholder.typicode.com over the
// network. That is bad in a unit test: it is slow, it needs Wi-Fi, and it
// can fail for reasons that have nothing to do with our code.
//
// Because `UsersVM` depends on the PROTOCOL `UsersRepositoryProtocol` and
// not on the concrete class, we can hand it this fake instead. The view
// model cannot tell the difference — and now we fully control what the
// "network" returns, including errors.

final class MockUsersRepository: UsersRepositoryProtocol {
    /// What `getUsers()` should do when called.
    /// `.success([...])` pretends the server replied, `.failure(...)`
    /// pretends something went wrong.
    var getUsersResult: Result<[User], Error> = .success([])
    
    /// Set to true once the method is called, so a test can verify
    /// that the view model actually asked the repository for data.
    private(set) var getUsersWasCalled = false
    
    func getUsers() async throws -> [User] {
        getUsersWasCalled = true
        return try getUsersResult.get()   // throws if the result is .failure
    }
}

final class MockPostsRepository: PostsRepositoryProtocol {
    var getPostsResult: Result<[Post], Error> = .success([])
    var getPostResult: Result<Post, Error> = .success(Fixtures.post())
    var createPostResult: Result<Post, Error> = .success(Fixtures.post())
    
    /// Records the id that was asked for, so a test can check that the
    /// right id was passed through.
    private(set) var requestedPostId: Int?
    /// Records the post that was sent, for the same reason.
    private(set) var createdPost: NewPost?
    
    func getPosts() async throws -> [Post] {
        try getPostsResult.get()
    }
    
    func getPost(id: Int) async throws -> Post {
        requestedPostId = id
        return try getPostResult.get()
    }
    
    func createPost(_ post: NewPost) async throws -> Post {
        createdPost = post
        return try createPostResult.get()
    }
}

extension Services {
    /// Builds a `Services` made entirely of mocks, for convenience.
    static func mocked(users: MockUsersRepository = MockUsersRepository(),
                       posts: MockPostsRepository = MockPostsRepository()) -> Services {
        Services(usersRepo: users, postsRepo: posts)
    }
}
