import RealHTTP

public protocol APIResourceConvertible {
    associatedtype Result: Decodable
    func request() -> HTTPRequest
}
public extension HTTPClient {
    func fetch<T: APIResourceConvertible>(_ resource: T) async throws -> T.Result {
        let response = try await resource.request().fetch(self)
        return try response.decode(T.Result.self, decoder: .snakeCaseDecoder())
    }
}
