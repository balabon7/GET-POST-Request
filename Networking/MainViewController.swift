//
//  MainViewController.swift
//  Networking
//
//  Created by mac on 10.08.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import UIKit

enum Actions: String, CaseIterable {
    case downloadImage = "Donwnload Image"
    case get = "GET"
    case post = "POST"
    case ourCourses = "OUR Courses"
    case uploadImage = "Upload Image"
    case downloadFile = "Download File"
}

private let reuseIdentifier = "Cell"
private let url = "https://jsonplaceholder.typicode.com/posts"
private let uploadImage = "https://api.imgur.com/3/image"

class MainViewController: UICollectionViewController {
    
    // let actions = ["Donwnload Image", "GET", "POST", "OUR Courses", "Upload Image"]
    let actions = Actions.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return actions.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        cell.label.text = actions[indexPath.row].rawValue
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let action = actions[indexPath.row]
        
        switch action {
        case Actions.downloadImage:
            performSegue(withIdentifier: "ShowImage", sender: self)
        case Actions.get:
            NetworkManager.getRequest(url: url)
        case Actions.post:
            NetworkManager.postRequest(url: url)
        case Actions.ourCourses:
            performSegue(withIdentifier: "OurCourses", sender: nil)
        case Actions.uploadImage:
            NetworkManager.uploadImage(url: uploadImage)
        case Actions.downloadFile:
            print(action.rawValue)
        }
    }
    
}
