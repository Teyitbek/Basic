import UIKit

struct Services {
    let usersRepo: UsersRepositoryProtocol
    let postsRepo: PostsRepositoryProtocol
    
    init(usersRepo: UsersRepositoryProtocol, postsRepo: PostsRepositoryProtocol) {
        self.usersRepo = usersRepo
        self.postsRepo = postsRepo
    }
}
