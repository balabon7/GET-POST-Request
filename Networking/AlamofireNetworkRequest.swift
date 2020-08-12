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
    
    static func sendRequest(url: String) {
        guard let url = URL(string: url) else { return }
        AF.request(url, method: .get).responseJSON { (response) in
            print(response)
        }
    }
}

