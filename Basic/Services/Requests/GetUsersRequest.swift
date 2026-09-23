import RealHTTP

struct GetUsersRequest: Codable, APIResourceConvertible {
    typealias Result = [User]
    
    func request() -> HTTPRequest {
        HTTPRequest {
            $0.path = Endpoint.baseURL + "/users"
            $0.method = .get
            $0.maxRetries = 3
        }
    }
}
