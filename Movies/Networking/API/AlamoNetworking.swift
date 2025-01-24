//
//  AlamoNetworking.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import Foundation
import Alamofire

final class AlamoNetworking<T: Endpoint> {
    
    enum Result {
        case data(Data?)
        case error(NetworkError)
    }
    
    private var host: String
    private var headers: [String : String]
    
    init(_ hostString: String, headers: [String : String] = [:]) {
        self.host = hostString
        self.headers = headers
    }
    
    func perform(
        _ method: HTTPMethod,
        _ endpoint: T,
        _ parameters: NetworkRequestBodyConvertible,
        completion: @escaping (Result) -> ()
    ) {
        AF.request(composeRequest(host + "/\(endpoint.pathComponent)", parameters),
                   method: method,
                   parameters: parameters.parameters,
                   headers: HTTPHeaders(headers))
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
                        completion(.error(error))
                        return
                    }
                    
                    completion(.error(error))
                } else {
                    completion(.data(response.data))
                }
            }
    }

    private func composeRequest(
        _ host: String,
        _ parameters: NetworkRequestBodyConvertible
    ) -> String {
        var urlComps = URLComponents(string: host)!
        urlComps.queryItems = parameters.queryItems
        return urlComps.url?.absoluteString ?? ""
    }
    
}
