import Foundation

@Observable
final class PostsVM {
    private(set) var posts: [Post] = []
    private(set) var errorMessage: String?
    private(set) var isLoading = false

    func load(using repository: PostsRepositoryProtocol) async {
        guard posts.isEmpty, errorMessage == nil else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            posts = try await repository.getPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
