import XCTest
@testable import ToDoTabbar

// MARK: - Details screen accessibility wiring
//
// `DetailsAccessibilityTests` checks the WORDING. This file checks that the
// wording actually reaches the views, and that the views opted in to the
// features that use it.
//
// You cannot assert "VoiceOver said this out loud" or "the magnifier appeared"
// from a unit test — those are UIKit's job, and the HUD only exists while a
// finger is held down. What you *can* pin down is every input UIKit needs, and
// that is where the bugs are: a label set on the wrong view, or a row that
// forgot to opt in.
//
// Note `loadViewIfNeeded()`: a view controller does not build its view until
// something asks for it. That call runs `viewDidLoad`, which is what pushes
// the details into the view.

final class EndpointDetailsAccessibilityTests: XCTestCase {

    /// Builds the screen already showing `details`, the way it looks after a
    /// row was tapped in a list.
    private func makeScreen(showing details: Details) -> EndpointDetailsVC {
        let vc = EndpointDetailsVC(contentView: EndpointDetailsCV(),
                                   viewModel: EndpointDetailsVM(title: "User Details",
                                                                source: .ready(details)))
        vc.loadViewIfNeeded()
        return vc
    }

    private var userDetails: Details {
        Fixtures.user(name: "Leanne Graham", email: "leanne@example.com").details
    }

    // MARK: - Header

    func test_header_isOneVoiceOverElement_withBothLinesInOneLabel() {
        let header = makeScreen(showing: userDetails).contentView.accessibilityFocusView

        // One element, not two: VoiceOver announces the whole header in a
        // single swipe instead of stopping at the title and then the email.
        XCTAssertTrue(header.isAccessibilityElement)
        XCTAssertEqual(header.accessibilityLabel, "Leanne Graham, leanne@example.com")
    }

    func test_header_hasTheHeaderTrait() {
        let header = makeScreen(showing: userDetails).contentView.accessibilityFocusView

        // The trait is what lets a VoiceOver user jump between headings with
        // the rotor instead of swiping through every row.
        XCTAssertTrue(header.accessibilityTraits.contains(.header))
    }

    func test_header_optsIntoTheLongPressMagnifier() {
        let header = makeScreen(showing: userDetails).contentView.accessibilityFocusView

        XCTAssertTrue(header.showsLargeContentViewer)
        XCTAssertEqual(header.largeContentTitle, "Leanne Graham\nleanne@example.com")
        XCTAssertNotNil(header.largeContentImage)
    }

    // MARK: - The interaction that drives the magnifier

    func test_contentView_installsTheLargeContentViewerInteraction() {
        let contentView = makeScreen(showing: userDetails).contentView

        // Without this interaction nothing happens on long press, no matter
        // how many views set `showsLargeContentViewer`.
        let hasInteraction = contentView.interactions.contains { $0 is UILargeContentViewerInteraction }

        XCTAssertTrue(hasInteraction)
    }

    // MARK: - Rows

    func test_row_namesTheFieldAsLabelAndTheContentAsValue() {
        let vc = makeScreen(showing: userDetails)

        // Ask the data source for the first cell, exactly as the table would.
        let cell = vc.tableView(vc.contentView.tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        // Read aloud as "Username, Bret".
        XCTAssertTrue(cell.isAccessibilityElement)
        XCTAssertEqual(cell.accessibilityLabel, "Username")
        XCTAssertEqual(cell.accessibilityValue, "Bret")
    }

    func test_row_optsIntoTheLongPressMagnifier() {
        let vc = makeScreen(showing: userDetails)

        let cell = vc.tableView(vc.contentView.tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        XCTAssertTrue(cell.showsLargeContentViewer)
        XCTAssertEqual(cell.largeContentTitle, "Username: Bret")
    }

    // MARK: - Dynamic Type

    func test_rowLabels_scaleWithTheUsersTextSize() {
        let vc = makeScreen(showing: userDetails)

        let cell = vc.tableView(vc.contentView.tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        // Without this flag the font is chosen once and never updates when the
        // user changes their text size in Settings.
        XCTAssertTrue(cell.textLabel?.adjustsFontForContentSizeCategory ?? false)
        XCTAssertTrue(cell.detailTextLabel?.adjustsFontForContentSizeCategory ?? false)
    }
}
