//
//  String+Extension.swift
//  Movies
//
//  Created by Dmytro Hetman on 24.01.2025.
//

import Foundation

extension String {
    
    func add(_ pathComponent: String, _ parameters: NetworkRequestBodyConvertible) -> String {
        let hostWithPath = self.appending(pathComponent)
        var urlComps = URLComponents(string: hostWithPath)!
        urlComps.queryItems = parameters.queryItems
        return urlComps.url?.absoluteString ?? ""
    }
    
}
