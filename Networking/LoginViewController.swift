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
import GoogleSignIn

class LoginViewController: UIViewController {
    
    var userProfile: UserProfile?
    
    lazy var loginButton: UIButton = {
        let button = FBLoginButton()
        button.frame = CGRect(x: 32, y: 360, width: view.frame.width - 64, height: 50)
        button.delegate = self
        return button
    }()
    
//    lazy var customFBLoginButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
//        button.setTitle("Login with Facebook", for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
//        button.setTitleColor(.white, for: .normal)
//        button.frame = CGRect(x: 32, y: 360 + 80, width: view.frame.width - 64, height: 50)
//        button.layer.cornerRadius = 4
//        button.addTarget(self, action: #selector(handleCastomLogin), for: .touchUpInside)
//        return button
//    }()
    
    lazy var googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.frame = CGRect(x: 32, y: 360 + 80, width: view.frame.width - 64, height: 50)
        return button
    }()
    
        lazy var customGoogleLoginButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = .white
            button.setTitle("Login with Google", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.setTitleColor(.gray, for: .normal)
            button.frame = CGRect(x: 32, y: 360 + 80 + 80, width: view.frame.width - 64, height: 50)
            button.layer.cornerRadius = 4
            button.addTarget(self, action: #selector(handleCastomLogin), for: .touchUpInside)
            return button
        }()
    
    lazy var signInWithEmail: UIButton = {
        
        let loginButton = UIButton()
        loginButton.frame = CGRect(x: 32, y: 360 + 80 + 80 + 80, width: view.frame.width - 64, height: 50)
        loginButton.setTitle("Sign In with Email", for: .normal)
        loginButton.addTarget(self, action: #selector(openSignInVC), for: .touchUpInside)
        loginButton.layer.borderWidth = 2.0
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.cornerRadius = 4
        
        return loginButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    private func setupViews() {
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        view.addSubview(loginButton)
        //view.addSubview(customFBLoginButton)
        view.addSubview(googleLoginButton)
        view.addSubview(customGoogleLoginButton)
        view.addSubview(signInWithEmail)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    @objc private func openSignInVC() {
         performSegue(withIdentifier: "SignIn", sender: self)
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
        
        let userData = ["name": userProfile?.name, "email": userProfile?.email ?? "noemail@gmail.com"]
        
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

//MARK: Google SDK

extension LoginViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("Failed into Google",error.localizedDescription)
            return
        }
        
        print("Successfully logged into Google")
        
        if let userName = user.profile.name, let userEmail = user.profile.email {
            
            let userData = ["name": userName, "email": userEmail]
            userProfile = UserProfile(data: userData)
        }
        
        guard let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (result, error) in
            
            if let error = error {
                print("Something went wrong with out Google user: \(error.localizedDescription)")
                return
            }
            
           print("Successfully logged into Firebase with Google")
            self.saveIntoFirebase()
        }
    }
    
    @objc private func handleCastomLogin() {
        
        GIDSignIn.sharedInstance()?.signIn()
        print("Custom google login button pressed")
        
    }
}
