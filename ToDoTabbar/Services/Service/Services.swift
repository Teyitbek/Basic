import UIKit

struct Services {
    let usersRepo: UsersRepository
    let postsRepo: PostsRepository
    
    init(usersRepo: UsersRepository, postsRepo: PostsRepository) {
        self.usersRepo = usersRepo
        self.postsRepo = postsRepo
    }
}
