import Foundation
import Combine

class UsersVM: VMProtocol {
    var onUserSelected: ((User) -> Void)?
    
    let successGetUsers = PassthroughSubject<Void, Never>()
    let errorMessage = PassthroughSubject<String, Never>()
    
    private let services: Services
    
    init(services: Services) {
        self.services = services
    }
    
    private(set) var users: [User] = []
    
    func getUsers() {
        Task { @MainActor in
            do {
                let response = try await services.usersRepo.getUsers()
                self.users = response
                successGetUsers.send(())
            } catch {
                errorMessage.send(error.localizedDescription)
            }
        }
    }
}

