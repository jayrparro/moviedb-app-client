//
//  ImageConfig.swift
//  Sine-sine
//
//  Created by Leo Parro on 20/7/19.
//  Copyright © 2019 Leo Parro. All rights reserved.
//

import Foundation
import ObjectMapper

class ImageConfig: Mappable {
    var baseUrl: String?
    var secureBaseUrl: String?
    var posterSizes: [String]?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        baseUrl <- map["base_url"]
        secureBaseUrl <- map["secure_base_url"]
        posterSizes <- map["poster_sizes"]
    }
}
