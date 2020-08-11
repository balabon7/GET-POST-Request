//
//  ImageProperties.swift
//  Networking
//
//  Created by mac on 11.08.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

import UIKit

struct ImageProperties {
    
    let key: String
    let data: Data
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        guard let data = image.pngData() else { return nil }
        self.data = data
    }
    
}
