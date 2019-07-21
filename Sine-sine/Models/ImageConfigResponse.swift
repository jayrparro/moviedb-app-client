//
//  ImageConfigResponse.swift
//  Sine-sine
//
//  Created by Leo Parro on 20/7/19.
//  Copyright © 2019 Leo Parro. All rights reserved.
//

import Foundation
import ObjectMapper

class ImageConfigResponse: Mappable {
    var images: ImageConfig?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        images <- map["images"]
    }
}
