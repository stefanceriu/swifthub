//
//  ApplicationController.swift
//  swifthub
//
//  Created by Stefan Ceriu on 23/04/2020.
//  Copyright © 2020 Stefan Ceriu. All rights reserved.
//

import UIKit
import Alamofire

class ApplicationController : LoginViewControllerDelegate {
    
    private let requestDispatcher: Session
    
    private let authService: AuthService
    private var serviceClient: ServiceClient?
    
    private let window: UIWindow
    private let rootViewController: UINavigationController
    private let loginViewController: LoginViewController
    private var repositoryListViewController: RepositoryListViewController?
    
    public init(windowScene: UIWindowScene) {
        
        self.requestDispatcher = Session.default
        self.authService = AuthService(requestDispatcher: self.requestDispatcher)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        self.loginViewController = LoginViewController()
        self.rootViewController = UINavigationController(rootViewController: self.loginViewController)
        self.rootViewController.isNavigationBarHidden = true
        
        self.loginViewController.delegate = self
        
        self.window.rootViewController = self.rootViewController
        self.window.windowScene = windowScene
        self.window.makeKeyAndVisible()
    }
    
    // MARK: LoginViewControllerDelegate
    
    func loginViewControllerDidRequestLogin(_: LoginViewController) {
        self.authService.requestLogin(presentationContextProvider: self.loginViewController) { (result) in
            switch result {
            case .success(let accessToken):
                self.serviceClient = ServiceClient(requestDispatcher: self.requestDispatcher, accessToken: accessToken)
                self.repositoryListViewController = RepositoryListViewController(RepositorySearchService(self.serviceClient!))
                self.rootViewController.pushViewController(self.repositoryListViewController!, animated: true)
                
            case .failure(let error):
                print("Failed logging in with error: \(error)")
            }
        }
    }
}
