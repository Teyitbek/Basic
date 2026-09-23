import XCTest
@testable import Basic

// MARK: - HomeVM tests
//
// `HomeVM` holds the list of endpoints shown on the Home tab. There is no
// logic to speak of — but these tests protect the CONTENT of that list.
// If someone later deletes a row or typos a path, a test fails instead of
// the bug reaching a user.

final class HomeVMTests: XCTestCase {
    
    private var sut: HomeVM!
    
    override func setUp() {
        super.setUp()
        sut = HomeVM()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_endpoints_containsTheFourExpectedRows() {
        XCTAssertEqual(sut.endpoints.count, 4)
        
        XCTAssertEqual(sut.endpoints.map { $0.method }, ["GET", "GET", "GET", "POST"])
        XCTAssertEqual(sut.endpoints.map { $0.path }, ["/users", "/posts", "/posts/1", "/posts"])
    }
    
    func test_endpoints_allPointAtTheSameAPI() {
        // `allSatisfy` returns true only if the check passes for every item.
        let allUseBaseURL = sut.endpoints.allSatisfy {
            $0.url.hasPrefix("https://jsonplaceholder.typicode.com")
        }
        
        XCTAssertTrue(allUseBaseURL)
    }
    
    func test_singlePostEndpoint_carriesTheIdToLoad() {
        // `kind` is what the coordinator switches on to decide where to go.
        // The third row must carry id 1, otherwise tapping "/posts/1"
        // would fetch the wrong post.
        let endpoint = sut.endpoints[2]
        
        // `if case` is how you look inside an enum that has an associated
        // value. If the shape does not match, we fail the test ourselves
        // with `XCTFail`.
        if case .post(let id) = endpoint.kind {
            XCTAssertEqual(id, 1)
        } else {
            XCTFail("Expected the third endpoint to be .post, got \(endpoint.kind)")
        }
    }
}
