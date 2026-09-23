import Foundation

enum EndpointKind: Hashable {
    case users
    case posts
    case post(id: Int)
    case createPost
}

/// `Hashable` because `NavigationLink(value:)` uses the value itself as the
/// route — there is no coordinator deciding what a tap means any more.
struct Endpoint: Hashable {
    static let baseURL = "https://jsonplaceholder.typicode.com"

    let method: String
    let path: String
    let kind: EndpointKind

    var url: String {
        Self.baseURL + path
    }

    var title: String {
        "\(method) \(path)"
    }

    /// Method padded to a fixed width so paths line up in a monospaced list.
    var listTitle: String {
        "\(method.padding(toLength: 7, withPad: " ", startingAt: 0))\(path)"
    }
}
