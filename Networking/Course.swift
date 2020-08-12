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
    var numberOfLessons: Int?
    var numberOfTests: Int?
    
    init?(json: [String: Any]) {
        let id = json["id"] as? Int
        let name = json["name"] as? String
        let link = json["link"] as? String
        let imageUrl = json["imageUrl"] as? String
        let numberOfLessons = json["number_of_lessons"] as? Int
        let numberOfTests = json["number_of_tests"] as? Int
        
        self.id = id
        self.name = name
        self.link = link
        self.imageUrl = imageUrl
        self.numberOfLessons = numberOfLessons
        self.numberOfTests = numberOfTests
        
    }
    
    static func getArray(from jsonArray: Any) -> [Course]? {
        
        guard let jsonArray = jsonArray as? Array<[String:Any]> else { return nil }
    
        return jsonArray.compactMap { Course(json: $0) }
    }
}

//static func getArray(from jsonArray: Any) -> [Course]? {
//
//    guard let jsonArray = jsonArray as? Array<[String:Any]> else { return nil }
//
//    var courses = [Course]()
//
//    for jsonObject in jsonArray {
//
//        if let course = Course(json: jsonObject) {
//            courses.append(course)
//        }
//    }
//    return courses
//}

//var number_of_lessons: Int?
//var number_of_tests: Int?



//struct Course: Decodable {
//
//    var id: Int?
//    var name: String?
//    var link: String?
//    var imageUrl: String?
//    var numberOfLessons: Int?
//    var numberOfTests: Int?
//}
