import Foundation

/// A plain value: the Home tab has no state to observe, only a fixed list.
struct HomeVM {
    let endpoints: [Endpoint] = [
        Endpoint(method: "GET", path: "/users", kind: .users),
        Endpoint(method: "GET", path: "/posts", kind: .posts),
        Endpoint(method: "GET", path: "/posts/1", kind: .post(id: 1)),
        Endpoint(method: "POST", path: "/posts", kind: .createPost)
    ]
}
