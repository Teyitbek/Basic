import Foundation
import Combine

class PostsVM: VMProtocol {
    var onPostSelected: ((Post) -> Void)?
    
    let successGetPosts = PassthroughSubject<Void, Never>()
    let errorMessage = PassthroughSubject<String, Never>()
    
    private let services: Services
    
    init(services: Services) {
        self.services = services
    }
    
    private(set) var posts: [Post] = []
    
    func getPosts() {
        Task { @MainActor in
            do {
                let response = try await services.postsRepo.getPosts()
                self.posts = response
                successGetPosts.send(())
            } catch {
                errorMessage.send(error.localizedDescription)
            }
        }
    }
}
