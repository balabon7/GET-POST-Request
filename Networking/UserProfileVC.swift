//
//  UserProfileVC.swift
//  Networking
//
//  Created by mac on 18.08.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class UserProfileVC: UIViewController {
    
    lazy var loginButton: UIButton = {
        let button = FBLoginButton()
        button.frame = CGRect(x: 32, y: view.frame.height - 172, width: view.frame.width - 64, height: 50)
        button.delegate = self
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        setupViews()
    }
    
    private func setupViews() {
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        view.addSubview(loginButton)
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
}

//MARK: - Facebook SDK
extension UserProfileVC: LoginButtonDelegate  {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            print(error?.localizedDescription as Any)
        }
        
        print("Successfully logged in with facebook")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        print("Did log out of facebook")
        openLoginViewController()
        
        
    }
    private func openLoginViewController(){

        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                    let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    loginViewController.modalPresentationStyle = .fullScreen
                    self.present(loginViewController, animated: true)
                    return
                }
        } catch let error {
            print("Failed to SignOut", error.localizedDescription)
        }
    }
}
