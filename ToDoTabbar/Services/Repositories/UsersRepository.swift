import RealHTTP
import Foundation

class UsersRepository {
    private let dataSource: UsersDataSource
    
    init(dataSource: UsersDataSource) {
        self.dataSource = dataSource
    }
    
    func getUsers() async throws -> [User] {
        try await dataSource.getUsers()
    }
}
