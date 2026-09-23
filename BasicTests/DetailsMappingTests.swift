import XCTest
@testable import Basic

// MARK: - Details mapping tests
//
// The details screen does not know about `User` or `Post`. Each of those
// converts itself into a `Details` value, and the screen only renders that.
//
// That conversion is where mistakes hide (a wrong label, a field shown
// twice, a field forgotten), and it is pure logic with no UI involved —
// which makes it a perfect thing to unit test.

final class DetailsMappingTests: XCTestCase {
    
    // MARK: - User
    
    func test_userDetails_putsNameAndEmailInTheHeader() {
        // GIVEN a user with known values
        let user = Fixtures.user(name: "Leanne Graham", email: "leanne@example.com")
        
        // WHEN we convert it for the details screen
        let details = user.details
        
        // THEN the header shows the name and the email
        XCTAssertEqual(details.title, "Leanne Graham")
        XCTAssertEqual(details.subtitle, "leanne@example.com")
        XCTAssertEqual(details.icon, "person.fill")
    }
    
    func test_userDetails_hasContactAddressAndCompanySections() {
        let details = Fixtures.user().details
        
        // `map` pulls just the titles out, which is easier to read than
        // checking sections[0].title, sections[1].title, ... one by one.
        let sectionTitles = details.sections.map { $0.title }
        
        XCTAssertEqual(sectionTitles, ["Contact", "Address", "Company"])
    }
    
    func test_userDetails_combinesLatitudeAndLongitudeIntoOneRow() {
        // The user's coordinates live in two separate fields but are shown
        // as a single "Geo" row, so the joining format is worth pinning down.
        let details = Fixtures.user().details
        
        // Find the row we care about instead of relying on its position —
        // that way the test keeps working if rows get reordered.
        let geoRow = details.sections
            .flatMap { $0.rows }
            .first { $0.title == "Geo" }
        
        // `geoRow` is optional, because `first` finds nothing if the row is
        // missing. Comparing with `?.` is safe: a missing row gives nil,
        // which is not equal to the expected string, so the test fails
        // rather than crashing.
        XCTAssertEqual(geoRow?.value, "-37.3159, 81.1496")
    }
    
    // MARK: - Post
    
    func test_postDetails_putsTitleInHeaderAndIdInSubtitle() {
        let post = Fixtures.post(id: 42, title: "Hello world")
        
        let details = post.details
        
        XCTAssertEqual(details.title, "Hello world")
        XCTAssertEqual(details.subtitle, "Post #42")
        XCTAssertEqual(details.icon, "doc.text.fill")
    }
    
    func test_postDetails_showsBodyTextInItsOwnSection() {
        let post = Fixtures.post(body: "The body of the post")
        
        let details = post.details
        let bodySection = details.sections.first { $0.title == "Body" }
        
        XCTAssertEqual(bodySection?.rows.first?.value, "The body of the post")
    }
    
    func test_postDetails_showsIdsAsText() {
        // `id` and `userId` are numbers in the model but must be strings
        // on screen. This checks the conversion happens.
        let post = Fixtures.post(id: 7, userId: 3)
        
        let details = post.details
        let postSection = details.sections.first { $0.title == "Post" }
        
        XCTAssertEqual(postSection?.rows.map { $0.value }, ["7", "3"])
    }
}
