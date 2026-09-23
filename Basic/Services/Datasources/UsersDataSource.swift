import Foundation
import RealHTTP

class UsersDataSource {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func getUsers() async throws -> [User] {
        try await client.fetch(GetUsersRequest())
    }
}
