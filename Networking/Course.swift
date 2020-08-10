//
//  Course.swift
//  Networking
//
//  Created by mac on 07.08.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import Foundation


struct Course: Decodable {
    
    var id: Int?
    var name: String?
    var link: String?
    var imageUrl: String?
    var number_of_lessons: Int?
    var number_of_tests: Int?
}
