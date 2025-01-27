//
//  NetworkError.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import Foundation
import Alamofire

enum NetworkError: Error, AlertError {
    case invalidAPIKey
    case noData
    case networkError
    case undefinedError
    case failedToDecodeGenres
    case failedToDecodeDetails
    case failedToParseDetailsModel
    case youAreOffline
}

extension NetworkError {
    var title: String {
        switch self {
        case .invalidAPIKey:
            "Error"
        case .noData:
            "Error"
        case .networkError:
            "Error"
        case .undefinedError:
            "Error"
        case .failedToDecodeGenres:
            "Error"
        case .failedToDecodeDetails:
            "Error"
        case .failedToParseDetailsModel:
            "Error"
        case .youAreOffline:
            "You are offline."
        }
    }
    
    var message: String {
        switch self {
        case .invalidAPIKey:
            "Invalid API key."
        case .noData:
            "Invalid no data got from API."
        case .networkError:
            "Some issues with network."
        case .undefinedError:
            "Undefined error. Connect developers with your issue."
        case .failedToDecodeGenres:
            "Failed to decode genres."
        case .failedToDecodeDetails:
            "Failed to decode details."
        case .failedToParseDetailsModel:
            "Failed to parse details model."
        case .youAreOffline:
            "Please, enable your Wi-Fi or connect using cellular data."
        }
    }
}
