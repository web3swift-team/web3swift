//
//  MainTabBarViewController.swift
//  Web3SwiftExample
//
//  Created by Максим Алексеев  on 04.11.2021.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK:- Private functions
    private func createTabController(_ controller: UIViewController, title: String, imageName: String) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.title = title
        navigationController.tabBarItem.image = UIImage(named: imageName)
        return navigationController
    }
}
