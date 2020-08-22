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
import FirebaseDatabase
import GoogleSignIn

class UserProfileVC: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var provider: String?
    private var currentUser: CurrentUser?
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 32, y: view.frame.height - 172, width: view.frame.width - 64, height: 50)
        button.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        userNameLabel.isHidden = true
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchingUserData()
    }
    
    private func setupViews() {
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        view.addSubview(logoutButton)
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    
}

//MARK: - SDK
extension UserProfileVC  {
    
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
    
    private func fetchingUserData() {
        
        if Auth.auth().currentUser != nil {
            
            if let userName = Auth.auth().currentUser?.displayName {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
                userNameLabel.isHidden = false
                userNameLabel.text = getProviderData(withUser: userName)
            } else {
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let userData = snapshot.value as? [String: Any] else { return }
                    
                    self.currentUser = CurrentUser(uid: uid, data: userData)
                    
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.userNameLabel.isHidden = false
                    self.userNameLabel.text = self.getProviderData(withUser: self.currentUser?.name ?? "Noname")
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @objc  private func signOut() {
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                
                switch userInfo.providerID {
                case "facebook.com":
                    LoginManager().logOut()
                    print("User did log out of facebook")
                    openLoginViewController()
                case "google.com":
                    GIDSignIn.sharedInstance()?.signOut()
                    print("User did log out of google")
                    openLoginViewController()
                case "password":
                    try! Auth.auth().signOut()
                    print("User did sign out")
                    openLoginViewController()
                default:
                    print("User is singed in with \(userInfo.providerID)")
                }
            }
        }
    }
    
    private func getProviderData(withUser user: String) -> String {
        var greetings = ""
        if let providerDara = Auth.auth().currentUser?.providerData {
            for userInfo in providerDara {
                
                switch userInfo.providerID {
                case "facebook.com":
                    provider = "Facebook"
                case "google.com":
                    provider = "Google"
                case "password":
                    provider = "Email"
                default:
                    break
                }
            }
            greetings = "\(user) Logged in with \(provider!)"
        }
        return greetings
    }
}
