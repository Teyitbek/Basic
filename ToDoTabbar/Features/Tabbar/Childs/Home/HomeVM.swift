import Foundation

class HomeVM {
    var onEndpointSelected: ((Endpoint) -> Void)?
    
    let endpoints: [Endpoint] = [
        Endpoint(method: "GET", path: "/users", kind: .users),
        Endpoint(method: "GET", path: "/posts", kind: .posts),
        Endpoint(method: "GET", path: "/posts/1", kind: .post(id: 1)),
        Endpoint(method: "POST", path: "/posts", kind: .createPost)
    ]
}
