//
//  LoginViewController.swift
//  swifthub
//
//  Created by Stefan Ceriu on 23/04/2020.
//  Copyright © 2020 Stefan Ceriu. All rights reserved.
//

import UIKit
import AuthenticationServices

protocol LoginViewControllerDelegate: AnyObject {
    func loginViewControllerDidRequestLogin(_: LoginViewController)
}

class LoginViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    
    weak var delegate: LoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: ASWebAuthenticationPresentationContextProviding
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // MARK: Private
    
    @IBAction private func onLoginButtonTap(sender: UIButton) {
        self.delegate?.loginViewControllerDidRequestLogin(self)
    }
}

