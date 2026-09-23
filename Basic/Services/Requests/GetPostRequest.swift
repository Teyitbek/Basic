import RealHTTP

struct GetPostRequest: Codable, APIResourceConvertible {
    typealias Result = Post
    
    let id: Int
    
    func request() -> HTTPRequest {
        HTTPRequest {
            $0.path = Endpoint.baseURL + "/posts/\(id)"
            $0.method = .get
            $0.maxRetries = 3
        }
    }
}
