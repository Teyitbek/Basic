import Foundation

@Observable
final class UsersVM {
    private(set) var users: [User] = []
    private(set) var errorMessage: String?
    private(set) var isLoading = false

    /// The repository arrives as an argument rather than being stored, so the
    /// view can create the view model before the environment is available.
    func load(using repository: UsersRepositoryProtocol) async {
        // `.task` re-runs when the view reappears; the list is already here.
        guard users.isEmpty, errorMessage == nil else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            users = try await repository.getUsers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
