//
//  Constants.swift
//  Sine-sine
//
//  Created by Leo Parro on 21/7/19.
//  Copyright © 2019 Leo Parro. All rights reserved.
//

import Foundation

struct K {
    struct ProductionServer {
        static let baseURL = "https://api.themoviedb.org/3"
        static let APIKey = "3a49683ac01d0fb6444735f467e46536"
    }
}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
}
