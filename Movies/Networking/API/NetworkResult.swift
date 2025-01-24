//
//  NetworkResult.swift
//  Movies
//
//  Created by Dmytro Hetman on 24.01.2025.
//

import Foundation

enum NetworkResult {
    case data(Data?)
    case error(NetworkError)
}
