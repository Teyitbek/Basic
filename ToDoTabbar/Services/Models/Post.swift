import Foundation

struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

struct NewPost: Codable {
    let title: String
    let body: String
    let userId: Int
    
    static let sample = NewPost(title: "New Post",
                                body: "Created from the ToDoTabbar app",
                                userId: 1)
}
