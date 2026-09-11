import UIKit

final class Factory {
    var services: Services
    
    init(services: Services) {
        self.services = services
    }
    
    func makeLoginVC() -> LoginVC {
        let contentView = LoginCV()
        let viewModel = LoginVM()
        return LoginVC(contentView: contentView, viewModel: viewModel)
    }
    
    func makeUsersVC() -> UsersVC {
        let contentView = UsersCV()
        let viewModel = UsersVM(services: services)
        return UsersVC(contentView: contentView, viewModel: viewModel)
    }
    
    func makePostsVC() -> PostsVC {
        let contentView = PostsCV()
        let viewModel = PostsVM(services: services)
        return PostsVC(contentView: contentView, viewModel: viewModel)
    }
    
    func makeEndpointDetailsVC(title: String, source: DetailsSource) -> EndpointDetailsVC {
        let contentView = EndpointDetailsCV()
        let viewModel = EndpointDetailsVM(title: title, source: source)
        return EndpointDetailsVC(contentView: contentView, viewModel: viewModel)
    }
}
