//
//  LoginViewController.swift
//  Networking
//
//  Created by mac on 18.08.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    var userProfile: UserProfile?
    
    lazy var loginButton: UIButton = {
        let button = FBLoginButton()
        button.frame = CGRect(x: 32, y: 360, width: view.frame.width - 64, height: 50)
        button.delegate = self
        return button
    }()
    
    lazy var customFBLoginButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        button.setTitle("Login with Facebook", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.frame = CGRect(x: 32, y: 360 + 60, width: view.frame.width - 64, height: 50)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(handleCastomLogin), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        view.addSubview(loginButton)
        view.addSubview(customFBLoginButton)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    
}

//MARK: - Facebook SDK
extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            print(error?.localizedDescription as Any)
        }
        
        guard let token = AccessToken.current, !token.isExpired else { return }
        
        signIntoFirebase()
        print("Successfully logged in with facebook")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        print("Did log out of facebook")
    }
    
    private func openMainViewController() {
        dismiss(animated: true)
    }
    
    @objc private func handleCastomLogin() {
        print("Custom login button pressed")
        
    }
    
    private func signIntoFirebase() {
        
        let accessToken = AccessToken.current
        
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credentials) { (user, error) in
            
            if let error = error {
                print("Auth facebook error",error.localizedDescription)
                return
            }
            
            print("Successfully loged in our FB user!")
            self.fetchFacebookFields()
        }
    }
    
    private func fetchFacebookFields() {
        
        GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start { (_, result, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let userData = result as? [String: Any] {
                self.userProfile = UserProfile(data: userData)
                print(self.userProfile?.name ?? "non name")
                self.saveIntoFirebase()
            }
        }
    }
    
    private func saveIntoFirebase(){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userData = ["name": userProfile?.name, "email": "testmail@gmail.com"]
        
        let values = [uid: userData]
        
        Database.database().reference().child("users").updateChildValues(values) { (dataError, _) in
            
            if let error = dataError {
                print(error.localizedDescription)
            }
            
            print("Successfully saved user into firebase database")
            self.openMainViewController()
        }
    }
    
}
