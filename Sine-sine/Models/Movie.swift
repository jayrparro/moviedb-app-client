//
//  Movie.swift
//  Sine-sine
//
//  Created by Leo Parro on 20/7/19.
//  Copyright © 2019 Leo Parro. All rights reserved.
//

import Foundation
import ObjectMapper

class Movie: Mappable {
    var id: Int = 0
    var title: String?
    var posterPath: String?
    var backdropPath: String?
    var releaseDate: String?
    var overview: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        posterPath <- map["poster_path"]
        backdropPath <- map["backdrop_path"]
        releaseDate <- map["release_date"]
        overview <- map["overview"]
        
    }
}
