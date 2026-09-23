import RealHTTP

struct GetPostsRequest: Codable, APIResourceConvertible {
    typealias Result = [Post]
    
    func request() -> HTTPRequest {
        HTTPRequest {
            $0.path = Endpoint.baseURL + "/posts"
            $0.method = .get
            $0.maxRetries = 3
        }
    }
}
