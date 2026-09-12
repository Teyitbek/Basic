import XCTest
@testable import ToDoTabbar

// MARK: - Accessibility text tests
//
// You cannot unit test what VoiceOver *sounds* like, but you can test the
// strings it is given — and that is where the mistakes are (a missing space,
// a field name spoken twice, an empty subtitle leaving a dangling comma).
//
// This is exactly why the wording lives on the model in
// `Details+Accessibility.swift` instead of inside the views: strings are easy
// to test, views are not.

final class DetailsAccessibilityTests: XCTestCase {

    // MARK: - Header

    func test_headerAccessibilityLabel_joinsTitleAndSubtitle() {
        // VoiceOver should read the header as one phrase, with a comma so it
        // pauses naturally between the two parts.
        let details = Fixtures.user(name: "Leanne Graham", email: "leanne@example.com").details

        XCTAssertEqual(details.accessibilityLabel, "Leanne Graham, leanne@example.com")
    }

    func test_headerAccessibilityLabel_withoutSubtitle_hasNoTrailingComma() {
        // A post with an empty subtitle must not be announced as
        // "Some title, " — the comma would be read as a pause into nothing.
        let details = Details(icon: "doc.text.fill",
                              title: "Some title",
                              subtitle: "",
                              sections: [])

        XCTAssertEqual(details.accessibilityLabel, "Some title")
    }

    func test_headerLargeContentTitle_putsSubtitleOnItsOwnLine() {
        // The magnifier HUD is a small box, so the two parts go on separate
        // lines instead of running together.
        let details = Fixtures.user(name: "Leanne Graham", email: "leanne@example.com").details

        XCTAssertEqual(details.largeContentTitle, "Leanne Graham\nleanne@example.com")
    }

    // MARK: - Rows

    func test_rowAccessibility_splitsFieldNameFromContent() {
        // The convention: the LABEL names the field, the VALUE is the content.
        // VoiceOver then reads "Username, Bret", and re-announces just the
        // value if it ever changes.
        let row = DetailsRow(title: "Username", value: "Bret")

        XCTAssertEqual(row.accessibilityLabel, "Username")
        XCTAssertEqual(row.accessibilityValue, "Bret")
    }

    func test_rowLargeContentTitle_showsFieldAndContentTogether() {
        // The HUD has no notion of label vs value, so it gets one string.
        let row = DetailsRow(title: "Phone", value: "1-770-736-8031")

        XCTAssertEqual(row.largeContentTitle, "Phone: 1-770-736-8031")
    }

    func test_everyRowOfAUser_hasNonEmptyAccessibilityText() {
        // A blank label makes VoiceOver announce a useless "blank" row. This
        // sweeps all of them at once, so a new field added to the mapping
        // without text is caught here.
        let details = Fixtures.user().details

        for row in details.sections.flatMap({ $0.rows }) {
            XCTAssertFalse(row.accessibilityLabel.isEmpty, "empty label for row: \(row.title)")
            XCTAssertFalse(row.accessibilityValue.isEmpty, "empty value for row: \(row.title)")
        }
    }
}
