import Foundation
@testable import ToDoTabbar

// MARK: - Fixtures
//
// A "fixture" is just a ready-made object used by tests.
//
// Why bother? A `User` has 8 properties. If every test built one by hand,
// the tests would be long and noisy, and the important part of the test
// (what we are actually checking) would be buried. So we build one here
// once, and let each test tweak only the part it cares about.

enum Fixtures {
    
    /// A complete, valid user. `name` and `email` are parameters because
    /// some tests care about those specific values.
    static func user(id: Int = 1,
                     name: String = "Leanne Graham",
                     email: String = "leanne@example.com") -> User {
        User(id: id,
             name: name,
             username: "Bret",
             email: email,
             address: Address(street: "Kulas Light",
                              suite: "Apt. 556",
                              city: "Gwenborough",
                              zipcode: "92998-3874",
                              geo: Geo(lat: "-37.3159", lng: "81.1496")),
             phone: "1-770-736-8031",
             website: "hildegard.org",
             company: Company(name: "Romaguera-Crona",
                              catchPhrase: "Multi-layered client-server",
                              bs: "harness real-time e-markets"))
    }
    
    static func post(id: Int = 1,
                     userId: Int = 1,
                     title: String = "A post title",
                     body: String = "A post body") -> Post {
        Post(id: id, userId: userId, title: title, body: body)
    }
}

/// A stand-in error for tests that need a failure to happen.
/// The actual error type does not matter, only that it *is* an error.
struct TestError: Error {}
