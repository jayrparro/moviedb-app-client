//
//  APIClient.swift
//  Sine-sine
//
//  Created by Leo Parro on 21/7/19.
//  Copyright © 2019 Leo Parro. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    case configuration
    case nowPlaying(page: Int)
    case similarMovies(movieId: Int)
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .configuration, .nowPlaying, .similarMovies:
            return .get
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .configuration:
            return "/configuration?api_key=\(K.ProductionServer.APIKey)"
        case .nowPlaying(let pageId):
            return "/movie/now_playing?api_key=\(K.ProductionServer.APIKey)&language=en-US&page=\(pageId)"
        case .similarMovies(let movieId):            
            return "/movie/\(movieId)/similar?api_key=\(K.ProductionServer.APIKey)&language=en-US&page=1"
        }
        
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .configuration, .nowPlaying, .similarMovies:
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        
        let apiUrl = K.ProductionServer.baseURL + path
        
        let urlPath = apiUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        var urlRequest = URLRequest(url: URL(string: urlPath)!)
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        // Parameters
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
}

class APIClient {
    static func configuration(completion: @escaping (Result<ImageConfigResponse>)->Void) {
        Alamofire.request(APIRouter.configuration).responseObject { (response: DataResponse<ImageConfigResponse>) in
            completion(response.result)
        }
    }
    
    static func nowPlaying(pageId: Int, completion: @escaping (Result<MovieResponse>)->Void) {
        Alamofire.request(APIRouter.nowPlaying(page: pageId)).responseObject { (response: DataResponse<MovieResponse>) in
            
            completion(response.result)
        }
    }
    
    static func similarMovies(movieId: Int, completion: @escaping (Result<MovieResponse>)->Void) {
        Alamofire.request(APIRouter.similarMovies(movieId: movieId)).responseObject { (response: DataResponse<MovieResponse>) in
            completion(response.result)
        }
    }
}
