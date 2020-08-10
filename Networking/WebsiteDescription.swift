//
//  WebsiteDescription.swift
//  Networking
//
//  Created by mac on 10.08.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import Foundation

struct WebsiteDescription: Decodable {
    
    var websiteDescription: String?
    var websiteName: String?
    var courses: [Course]
}
