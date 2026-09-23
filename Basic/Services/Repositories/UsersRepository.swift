import RealHTTP
import Foundation

/// The contract the app depends on. Tests provide their own implementation
/// of it, so a view model can be checked without making a real network call.
protocol UsersRepositoryProtocol {
    func getUsers() async throws -> [User]
}

class UsersRepository: UsersRepositoryProtocol {
    private let dataSource: UsersDataSource
    
    init(dataSource: UsersDataSource) {
        self.dataSource = dataSource
    }
    
    func getUsers() async throws -> [User] {
        try await dataSource.getUsers()
    }
}
