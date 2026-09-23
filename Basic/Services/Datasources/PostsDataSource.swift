import Foundation
import RealHTTP

class PostsDataSource {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func getPosts() async throws -> [Post] {
        try await client.fetch(GetPostsRequest())
    }
    
    func getPost(id: Int) async throws -> Post {
        try await client.fetch(GetPostRequest(id: id))
    }
    
    func createPost(_ post: NewPost) async throws -> Post {
        try await client.fetch(CreatePostRequest(post: post))
    }
}
