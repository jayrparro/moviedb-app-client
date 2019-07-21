//
//  Config.swift
//  Sine-sine
//
//  Created by Leo Parro on 20/7/19.
//  Copyright © 2019 Leo Parro. All rights reserved.
//

import Foundation

class Config {
    static let shared = Config()
        
    var configImageBaseUrl: String?
    var configImagePosterSize: String?
    
    private init() {}
}
