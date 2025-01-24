//
//  AlamoNetworking.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import Foundation
import Alamofire

protocol AlamoNetworkingServiceProtocol {
    func perform(
        _ method: HTTPMethod,
        _ endpoint: Endpoint,
        _ parameters: NetworkRequestBodyConvertible,
        completion: @escaping (NetworkResult) -> Void
    )
}

final class AlamoNetworking<T: Endpoint>: AlamoNetworkingServiceProtocol {
    
    private var host: String
    private var headers: [String : String]
    
    init(_ hostString: String, headers: [String : String] = [:]) {
        self.host = hostString
        self.headers = headers
    }
    
    func perform(
        _ method: HTTPMethod,
        _ endpoint: Endpoint,
        _ parameters: NetworkRequestBodyConvertible,
        completion: @escaping (NetworkResult) -> Void
    ) {
        
        AF.request(
            host.add("/\(endpoint.pathComponent)", parameters),
            method: method,
            parameters: parameters.parameters,
            headers: HTTPHeaders(headers)
        )
        .response { response in
            if let _ = response.error {
                var error: NetworkError = .undefinedError
                if let httpResponse = response.response {
                    switch httpResponse.statusCode {
                    case 401:
                        error = .invalidAPIKey
                    case 404, 422:
                        error = .noData
                    default:
                        error = .networkError
                    }
                }
                completion(.error(error))
            } else {
                completion(.data(response.data))
            }
        }
    }
    
}
