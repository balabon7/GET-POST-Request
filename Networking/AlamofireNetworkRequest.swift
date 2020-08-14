//
//  AlamofireNetworkRequest.swift
//  Networking
//
//  Created by mac on 12.08.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireNetworkRequest {
    
    static var onProgress: ((Double)->())?
    static var completed: ((String)->())?
    
    static func sendRequest(url: String, completion: @escaping (_ courses: [Course]) -> ())  {
        guard let url = URL(string: url) else { return }
        AF.request(url, method: .get).validate().responseJSON { (response) in
            
            switch response.result {
                
            case .success(let value):
                
                var courses = [Course]()
                
                courses = Course.getArray(from: value)!
                
                completion(courses)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func responseData(url: String) {
        guard let url = URL(string: url) else { return }
        AF.request(url).responseData { (responseData) in
            
            switch responseData.result {
            case .success(let data):
                guard let string = String(data: data, encoding: .utf8) else { return }
                print(string)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func responseString(url: String) {
        guard let url = URL(string: url) else { return }
        AF.request(url).responseString { (responseString) in
            
            switch responseString.result {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func response(url: String) {
        guard let url = URL(string: url) else { return }
        
        AF.request(url).response { (response) in
            guard let data = response.data, let string = String(data: data, encoding: .utf8) else { return }
            
            print(data)
            print(string)
        }
        
    }
    
    static func downloadImage(url: String, completion: @escaping (_ image: UIImage)->()) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).responseData { (responseData) in
            
            switch responseData.result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                completion(image)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    static func downloadImageWithProgress(url: String, completion: @escaping (_ image: UIImage)->()) {
        
        guard let url = URL(string: url) else { return }
        
        AF.request(url).validate().downloadProgress { (progress) in
            print(progress)
            print("Total Unit Count: \(progress.totalUnitCount)\n")
            print("Completed Unit Count: \(progress.completedUnitCount)\n")
            print("fraction Completed: \(progress.fractionCompleted)\n")
            print("Localized Description: \(String(describing: progress.localizedDescription))\n")
            print("---------------------------------------------------------")
            
            self.onProgress?(progress.fractionCompleted)
            self.completed?(progress.localizedDescription)
        }.response { (response) in
            guard let data = response.data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    static func postRequest(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        guard let url = URL(string: url) else { return }
        
        let userData: [String: Any] = [
            "name": "Network Requests with Alamofire",
            "link": "https://swiftbook.ru/contents/our-first-applications/",
            "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png",
            "numberOfLessons": "18",
            "numberOfTests": "10"
        ]
        
        AF.request(url, method: .post, parameters: userData).responseJSON { (responseJSON) in
            
            guard let statusCode = responseJSON.response?.statusCode else { return }
            
            print(statusCode)
            
            switch responseJSON.result {
            case .success(let value):
                print(value)
                guard let jsonObject = value as? [String : Any],
                    let course = Course(json: jsonObject) else { return }
                
                var courses = [Course]()
                courses.append(course)
                completion(courses)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func putRequest(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        guard let url = URL(string: url) else { return }
        
        let userData: [String: Any] = [
            "name": "Network Put Request",
            "link": "https://swiftbook.ru/contents/our-first-applications/",
            "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png",
            "numberOfLessons": 18,
            "numberOfTests": 10
        ]
        
        AF.request(url, method: .put, parameters: userData).responseJSON { (responseJSON) in
            
            guard let statusCode = responseJSON.response?.statusCode else { return }
            
            print(statusCode)
            
            switch responseJSON.result {
            case .success(let value):
                print(value)
                guard let jsonObject = value as? [String : Any],
                    let course = Course(json: jsonObject) else { return }
                
                var courses = [Course]()
                courses.append(course)
                completion(courses)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    static func uploadImage(url: String){
        
        guard let url = URL(string: url) else { return }
        
        let image = UIImage(named: "Notification")!
        let data = image.pngData()
        let httpHeaders: HTTPHeaders = ["Authorization": "Client-ID 47c7bc00a214ae1"]
        
        print("start uploadImage")
        
        AF.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(data!, withName: "image")
            
        }, to: url, headers: httpHeaders).responseJSON { response in
            
            switch response.result {
                
            case .success(let value):
                print(value)
            case .failure(let error):
                print(error)
            }
        }
    }
}
