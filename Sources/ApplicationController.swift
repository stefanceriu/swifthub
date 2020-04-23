//
//  ApplicationController.swift
//  swifthub
//
//  Created by Stefan Ceriu on 23/04/2020.
//  Copyright © 2020 Stefan Ceriu. All rights reserved.
//

import UIKit

class ApplicationController : LoginViewControllerDelegate {
    
    private let window: UIWindow
    private let loginViewController: LoginViewController
    
    private let authService: AuthService
    
    public init(windowScene: UIWindowScene) {
        
        self.authService = AuthService()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        self.loginViewController = LoginViewController()
        self.loginViewController.delegate = self
        
        self.window.rootViewController = self.loginViewController
        self.window.makeKeyAndVisible()
        window.windowScene = windowScene
    }
    
    // MARK: LoginViewControllerDelegate
    
    func loginViewControllerDidRequestLogin(_: LoginViewController) {
        self.authService.requestLogin(presentationContextProvider: self.loginViewController) { (result) in
            switch result {
            case .success(let accessToken):
                print("Received access token: \(accessToken)")
            case .failure(let error):
                print("Failed logging in with error: \(error)")
            }
        }
    }
}
