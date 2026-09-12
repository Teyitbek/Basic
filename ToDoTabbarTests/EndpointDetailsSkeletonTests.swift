import XCTest
@testable import ToDoTabbar

// MARK: - Skeleton loading state
//
// What is worth testing here is the STATE MACHINE, not the pixels: which
// views are visible when, and that the placeholder never lingers or gets
// shown when there is nothing to wait for. Whether a block is 18pt tall is
// design, and design belongs in a screenshot, not an assertion.

final class EndpointDetailsSkeletonTests: XCTestCase {

    private func makeScreen(source: DetailsSource) -> EndpointDetailsVC {
        let vc = EndpointDetailsVC(contentView: EndpointDetailsCV(),
                                   viewModel: EndpointDetailsVM(title: "GET /posts/1", source: source))
        vc.loadViewIfNeeded()
        return vc
    }

    // MARK: - When it shows

    func test_remoteSource_showsTheSkeletonWhileLoading() {
        // A `.remote` screen has nothing to display yet, so the placeholder
        // stands in for the real layout.
        let contentView = makeScreen(source: .remote {
            Fixtures.post().details
        }).contentView

        XCTAssertTrue(contentView.isShowingSkeleton)
    }

    func test_readySource_neverShowsTheSkeleton() {
        // The data was handed over ready-made (a row tapped in a list), so
        // flashing a placeholder would be pure noise.
        let contentView = makeScreen(source: .ready(Fixtures.user().details)).contentView

        XCTAssertFalse(contentView.isShowingSkeleton)
    }

    func test_afterLoading_theSkeletonIsReplacedByTheContent() {
        let vc = makeScreen(source: .remote { Fixtures.post(title: "Loaded").details })

        // The screen deliberately keeps the placeholder up for a moment, so
        // wait for the swap rather than checking immediately.
        wait(until: { vc.contentView.isShowingSkeleton == false }, timeout: 5)

        XCTAssertFalse(vc.contentView.isShowingSkeleton)
    }

    func test_theSkeletonStaysUpLongEnoughToBeSeen() {
        // The whole point of the minimum duration: a fast response must not
        // make the placeholder flash for a single frame.
        let start = Date()
        let vc = makeScreen(source: .remote { Fixtures.post().details })

        wait(until: { vc.contentView.isShowingSkeleton == false }, timeout: 5)

        let visibleFor = Date().timeIntervalSince(start)
        XCTAssertGreaterThanOrEqual(visibleFor, EndpointDetailsSkeletonView.shimmerDuration)
    }

    // MARK: - Accessibility

    func test_theSkeleton_announcesItselfAsLoading() {
        // VoiceOver should say the screen is busy, not read out a pile of
        // meaningless empty shapes.
        let skeleton = EndpointDetailsSkeletonView()

        XCTAssertTrue(skeleton.isAccessibilityElement)
        XCTAssertEqual(skeleton.accessibilityLabel, "Loading")
    }
}
