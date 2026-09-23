import XCTest
@testable import Basic

// MARK: - Endpoint tests
//
// `Endpoint` is a plain value type with three computed properties.
// These are the easiest tests you will ever write: no setUp, no mocks,
// no waiting. Give it an input, check the output.
//
// Small as they are, they are worth having: `listTitle` does string
// padding, and padding logic is easy to break by accident later.

final class EndpointTests: XCTestCase {
    
    func test_url_joinsBaseURLAndPath() {
        let endpoint = Endpoint(method: "GET", path: "/users", kind: .users)
        
        XCTAssertEqual(endpoint.url, "https://jsonplaceholder.typicode.com/users")
    }
    
    func test_title_isMethodAndPath() {
        let endpoint = Endpoint(method: "GET", path: "/posts/1", kind: .post(id: 1))
        
        XCTAssertEqual(endpoint.title, "GET /posts/1")
    }
    
    func test_listTitle_padsMethodToTheSameWidth() {
        // This is the whole point of `listTitle`: in the Home list the paths
        // must line up under each other, even though GET and POST have
        // different lengths. So both strings must start the path at the
        // same character position.
        let get = Endpoint(method: "GET", path: "/posts", kind: .posts)
        let post = Endpoint(method: "POST", path: "/posts", kind: .createPost)
        
        XCTAssertEqual(get.listTitle, "GET    /posts")
        XCTAssertEqual(post.listTitle, "POST   /posts")
        
        // Same length = aligned on screen (with a monospaced font).
        XCTAssertEqual(get.listTitle.count, post.listTitle.count)
    }
}
