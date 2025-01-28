//
//  AppDelegate.swift
//  Movies
//
//  Created by Dmytro Hetman on 22.01.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var router: RouterProtocol?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        router = Router(navigationController: navigationController, assemblyBuilder: AssemblyModelBuilder())
        router?.startMoviesListViewController()
        
        window?.rootViewController = router?.navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    

}
