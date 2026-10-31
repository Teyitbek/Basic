import XCTest
@testable import Basic

// MARK: - EndpointDetailsVM tests
//
// This view model has two modes, and each deserves its own tests:
//
//   .ready(details)  — the data is already here (a row was tapped in a list)
//                      so the screen must show it straight away.
//   .remote { ... }  — the data must be fetched first, so the screen shows a
//                      skeleton, then either the content or an error.
//
// Notice that `.remote` takes a closure. That makes testing easy: we pass a
// closure returning whatever we want, without any network involved.

final class EndpointDetailsVMTests: XCTestCase {

    private var sut: EndpointDetailsVM!

    override func setUp() {
        super.setUp()
        sut = EndpointDetailsVM()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Ready

    func test_readySource_showsDetailsWithoutLoading() async {
        let details = Fixtures.user(name: "Leanne Graham").details

        await sut.load(from: .ready(details))

        XCTAssertEqual(sut.details?.title, "Leanne Graham")
        // No skeleton: flashing a placeholder over content we already have
        // would just be noise.
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Remote

    func test_beforeLoading_thereAreNoDetails() {
        XCTAssertNil(sut.details)
        XCTAssertNil(sut.errorMessage)
    }

    func test_load_onSuccess_storesTheLoadedDetails() async {
        await sut.load(from: .remote {
            Fixtures.post(id: 42, title: "Loaded post").details
        })

        XCTAssertEqual(sut.details?.title, "Loaded post")
        XCTAssertEqual(sut.details?.subtitle, "Post #42")
    }

    func test_load_onFailure_reportsAnErrorMessage() async {
        await sut.load(from: .remote { throw TestError() })

        // We only check that SOME message arrived, not its exact wording: the
        // text comes from the system and could change between iOS versions.
        // Asserting on it would make the test fragile.
        XCTAssertFalse(sut.errorMessage?.isEmpty ?? true)
        XCTAssertNil(sut.details)
    }

    func test_load_whenCalledAgain_doesNotRefetch() async {
        // `.task` re-runs when the view reappears; the details are already here.
        await sut.load(from: .remote { Fixtures.post(title: "First").details })
        await sut.load(from: .remote { Fixtures.post(title: "Second").details })

        XCTAssertEqual(sut.details?.title, "First")
    }

    // MARK: - Skeleton timing

    func test_load_keepsTheSkeletonUpLongEnoughToBeSeen() async {
        // The whole point of the minimum duration: a fast response must not
        // make the placeholder flash for a single frame.
        let start = Date()

        await sut.load(from: .remote { Fixtures.post().details })

        let elapsed = Date().timeIntervalSince(start)
        XCTAssertGreaterThanOrEqual(elapsed, SkeletonView.shimmerDuration)
    }

    func test_afterLoading_isLoadingIsSwitchedBackOff() async {
        await sut.load(from: .remote { throw TestError() })

        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Empty and error states

    func test_afterLoadingNothing_theScreenIsEmpty() async {
        // An endpoint can answer with no sections to show. The screen must
        // say so rather than render a blank rectangle.
        await sut.load(from: .remote {
            Details(icon: "tray", title: "", subtitle: "", sections: [])
        })

        XCTAssertTrue(sut.isEmpty)
    }

    func test_afterLoadingContent_theScreenIsNotEmpty() async {
        await sut.load(from: .ready(Fixtures.post().details))

        XCTAssertFalse(sut.isEmpty)
    }

    func test_onFailure_theAlertIsShown() async {
        await sut.load(from: .remote { throw TestError() })

        XCTAssertTrue(sut.isShowingError)
    }

    func test_dismissingTheAlert_clearsTheError() async {
        // The alert is bound to this flag, so turning it off has to clear the
        // message — otherwise the alert reappears immediately.
        await sut.load(from: .remote { throw TestError() })

        sut.isShowingError = false

        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isShowingError)
    }
}
