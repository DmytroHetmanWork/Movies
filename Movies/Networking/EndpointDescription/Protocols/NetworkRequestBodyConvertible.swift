//
//  NetworkRequestBodyConvertible.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import Foundation

protocol NetworkRequestBodyConvertible {
    
    var data: Data? { get }
    var queryItems: [URLQueryItem]? { get }
    var parameters: [String : Any]? { get }
    
}
