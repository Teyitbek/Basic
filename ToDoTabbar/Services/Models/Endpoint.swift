import Foundation

enum EndpointKind {
    case users
    case posts
    case post(id: Int)
    case createPost
}

struct Endpoint {
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
