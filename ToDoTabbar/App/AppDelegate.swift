//
//  AppDelegate.swift
//  ToDoTabbar
//
//  Created by Teyit Ajimamatov on 30/10/25.
//

import UIKit
import RealHTTP

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private let navigation = UINavigationController()
    private var coordinator: Coordinator?
    private var factory: Factory!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let url = URL(string: Endpoint.baseURL) else { return false }
        let client = HTTPClient(baseURL: url)
        let userRepository = UsersRepository(dataSource: UsersDataSource(client: client))
        let postsRepository = PostsRepository(dataSource: PostsDataSource(client: client))
        let services = Services(usersRepo: userRepository, postsRepo: postsRepository)
        
        factory = Factory(services: services)
        
        coordinator = Coordinator(navigation: navigation, services: services, factory: factory)
        coordinator?.start()
        
        window = UIWindow()
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
        
        return true
    }
}

