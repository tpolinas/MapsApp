//
//  AppStartManager.swift
//  MapsApp
//
//  Created by Polina Tikhomirova on 22.11.2022.
//

import UIKit

final class AppStartManager {
    
    var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    func start() {
        let rootVC = LoginViewController()
        let navVC = self.configureNavigationController
        navVC.viewControllers = [rootVC]
        
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }
    
    private lazy var configureNavigationController: UINavigationController = {
        let navVC = UINavigationController()
        navVC.navigationBar.isTranslucent = false
        
        return navVC
    }()
}
