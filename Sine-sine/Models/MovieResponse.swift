//
//  MovieResponse.swift
//  Sine-sine
//
//  Created by Leo Parro on 20/7/19.
//  Copyright © 2019 Leo Parro. All rights reserved.
//

import Foundation
import ObjectMapper

class MovieResponse: Mappable {
    var page: Int = 0
    var movies: [Movie]?
    var totalPages: Int = 0
    var totalResults: Int = 0
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        page <- map["page"]
        movies <- map["results"]
        totalPages <- map["total_pages"]
        totalResults <- map["total_results"]    
    }
}
