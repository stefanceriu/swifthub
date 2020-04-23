//
//  LoginViewController.swift
//  swifthub
//
//  Created by Stefan Ceriu on 23/04/2020.
//  Copyright © 2020 Stefan Ceriu. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    func loginViewControllerDidRequestLogin(_: LoginViewController)
}

class LoginViewController: UIViewController {
    
    var delegate: LoginViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func onLoginButtonTap(sender: UIButton) {
        self.delegate?.loginViewControllerDidRequestLogin(self)
    }
}

