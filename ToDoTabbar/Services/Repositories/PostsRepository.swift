import RealHTTP
import Foundation

class PostsRepository {
    private let dataSource: PostsDataSource
    
    init(dataSource: PostsDataSource) {
        self.dataSource = dataSource
    }
    
    func getPosts() async throws -> [Post] {
        try await dataSource.getPosts()
    }
    
    func getPost(id: Int) async throws -> Post {
        try await dataSource.getPost(id: id)
    }
    
    func createPost(_ post: NewPost) async throws -> Post {
        try await dataSource.createPost(post)
    }
}
