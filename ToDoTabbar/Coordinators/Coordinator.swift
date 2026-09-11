import UIKit

final class Coordinator {
    private let navigation: UINavigationController
    private let services: Services
    private let factory: Factory
        
    init(navigation: UINavigationController, services: Services, factory: Factory) {
        self.navigation = navigation
        self.services = services
        self.factory = factory
    }
    
    func start() {
        openLogin()
    }
    
    private func openLogin() {
        let vc = factory.makeLoginVC()
        vc.viewModel.onLoginSuccess = { [weak self] in
            self?.openTabbar()
        }
        navigation.setViewControllers([vc], animated: false)
    }
    
    private func openTabbar() {
        let vc = TabbarVC()
        vc.homeVC.vm.onEndpointSelected = { [weak self] endpoint in
            self?.open(endpoint)
        }
        navigation.setViewControllers([vc], animated: true)
    }
    
    private func open(_ endpoint: Endpoint) {
        switch endpoint.kind {
        case .users:
            openUsers()
        case .posts:
            openPosts()
        case .post(let id):
            openDetails(title: endpoint.title, source: .remote { [services] in
                try await services.postsRepo.getPost(id: id).details
            })
        case .createPost:
            openDetails(title: endpoint.title, source: .remote { [services] in
                try await services.postsRepo.createPost(.sample).details
            })
        }
    }
    
    private func openUsers() {
        let vc = factory.makeUsersVC()
        vc.viewModel.onUserSelected = { [weak self] user in
            self?.openDetails(title: "User Details", source: .ready(user.details))
        }
        navigation.pushViewController(vc, animated: true)
    }
    
    private func openPosts() {
        let vc = factory.makePostsVC()
        vc.viewModel.onPostSelected = { [weak self] post in
            self?.openDetails(title: "Post Details", source: .ready(post.details))
        }
        navigation.pushViewController(vc, animated: true)
    }
    
    private func openDetails(title: String, source: DetailsSource) {
        let vc = factory.makeEndpointDetailsVC(title: title, source: source)
        navigation.pushViewController(vc, animated: true)
    }
}
