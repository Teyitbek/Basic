import RealHTTP

struct CreatePostRequest: APIResourceConvertible {
    typealias Result = Post
    
    let post: NewPost
    
    func request() -> HTTPRequest {
        HTTPRequest {
            $0.path = Endpoint.baseURL + "/posts"
            $0.method = .post
            $0.body = .json(post)
        }
    }
}
