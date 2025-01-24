//
//  String+Extension.swift
//  Movies
//
//  Created by Dmytro Hetman on 24.01.2025.
//

import Foundation

extension String {
    
    func add(_ pathComponent: String, _ parameters: NetworkRequestBodyConvertible) -> String {
        var urlComps = URLComponents(string: self)!
        urlComps.queryItems = parameters.queryItems
        return urlComps.url?.absoluteString ?? ""
    }
    
}
