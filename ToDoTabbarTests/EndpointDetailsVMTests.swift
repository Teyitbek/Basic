import XCTest
import Combine
@testable import ToDoTabbar

// MARK: - EndpointDetailsVM tests
//
// This view model has two modes, and each deserves its own tests:
//
//   .ready(details)  — the data is already here (a row was tapped in a list)
//                      so the screen must show it straight away.
//   .remote { ... }  — the data must be fetched first, so the screen shows
//                      a spinner, then either the content or an error.
//
// Notice that `.remote` takes a closure. That makes testing easy: we pass
// a closure that returns whatever we want, without any network involved.

final class EndpointDetailsVMTests: XCTestCase {
    
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        bag = []
    }
    
    override func tearDown() {
        bag = nil
        super.tearDown()
    }
    
    // MARK: - Ready
    
    func test_readySource_hasDetailsImmediately() {
        let details = Fixtures.user(name: "Leanne Graham").details
        
        let sut = EndpointDetailsVM(title: "User Details", source: .ready(details))
        
        // `isReady` is what the screen checks to decide whether to show a
        // spinner. With ready data there must be no spinner at all.
        XCTAssertTrue(sut.isReady)
        XCTAssertEqual(sut.details?.title, "Leanne Graham")
    }
    
    func test_title_isTheOnePassedIn() {
        // The title becomes the navigation bar title of the screen.
        let sut = EndpointDetailsVM(title: "GET /posts/1", source: .ready(Fixtures.post().details))
        
        XCTAssertEqual(sut.title, "GET /posts/1")
    }
    
    // MARK: - Remote
    
    func test_remoteSource_isNotReadyBeforeLoading() {
        let sut = EndpointDetailsVM(title: "GET /posts/1", source: .remote {
            Fixtures.post().details
        })
        
        // Nothing has been fetched yet, so the screen shows a spinner.
        XCTAssertFalse(sut.isReady)
        XCTAssertNil(sut.details)
    }
    
    func test_getDetails_onSuccess_storesTheLoadedDetails() {
        // GIVEN a source that will "load" post 42
        let sut = EndpointDetailsVM(title: "GET /posts/42", source: .remote {
            Fixtures.post(id: 42, title: "Loaded post").details
        })
        
        let expectation = expectation(description: "successGetDetails is published")
        sut.successGetDetails
            .sink { _ in expectation.fulfill() }
            .store(in: &bag)
        
        // WHEN the screen asks for the data
        sut.getDetails()
        
        wait(for: [expectation], timeout: 1)
        
        // THEN it is stored and ready to render
        XCTAssertEqual(sut.details?.title, "Loaded post")
        XCTAssertEqual(sut.details?.subtitle, "Post #42")
    }
    
    func test_getDetails_onFailure_publishesAnErrorMessage() {
        // GIVEN a source that throws instead of returning data
        let sut = EndpointDetailsVM(title: "GET /posts/42", source: .remote {
            throw TestError()
        })
        
        let expectation = expectation(description: "errorMessage is published")
        var receivedMessage: String?
        sut.errorMessage
            .sink { message in
                receivedMessage = message
                expectation.fulfill()
            }
            .store(in: &bag)
        
        sut.getDetails()
        
        wait(for: [expectation], timeout: 1)
        
        // We only check that SOME message arrived, not its exact wording:
        // the text comes from the system and could change between iOS
        // versions. Asserting on it would make the test fragile.
        XCTAssertFalse(receivedMessage?.isEmpty ?? true)
        XCTAssertNil(sut.details)
    }
    
    func test_getDetails_onReadySource_doesNothing() {
        // Calling load on data we already have must not wipe it out.
        let sut = EndpointDetailsVM(title: "User Details",
                                    source: .ready(Fixtures.user(name: "Leanne Graham").details))
        
        sut.getDetails()
        
        XCTAssertEqual(sut.details?.title, "Leanne Graham")
    }
}
