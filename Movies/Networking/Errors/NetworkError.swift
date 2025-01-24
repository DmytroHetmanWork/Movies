//
//  NetworkError.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import Foundation
import Alamofire

enum NetworkError: Error {
    case invalidAPIKey
    case noData
    case networkError
    case undefinedError
}
