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
}

