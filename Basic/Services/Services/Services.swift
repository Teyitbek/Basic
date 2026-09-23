import Foundation
import RealHTTP

struct Services {
    let usersRepo: UsersRepositoryProtocol
    let postsRepo: PostsRepositoryProtocol

    init(usersRepo: UsersRepositoryProtocol, postsRepo: PostsRepositoryProtocol) {
        self.usersRepo = usersRepo
        self.postsRepo = postsRepo
    }
}

extension Services {
    /// The real services, talking to jsonplaceholder. One HTTP client is
    /// shared by both repositories.
    static let live: Services = {
        guard let url = URL(string: Endpoint.baseURL) else {
            preconditionFailure("Invalid base URL: \(Endpoint.baseURL)")
        }
        let client = HTTPClient(baseURL: url)
        return Services(usersRepo: UsersRepository(dataSource: UsersDataSource(client: client)),
                        postsRepo: PostsRepository(dataSource: PostsDataSource(client: client)))
    }()
}
