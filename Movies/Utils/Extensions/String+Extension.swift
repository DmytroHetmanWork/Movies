//
//  String+Extension.swift
//  Movies
//
//  Created by Dmytro Hetman on 24.01.2025.
//

import Foundation
import UIKit

extension String {
    func add(_ pathComponent: String, _ parameters: NetworkRequestBodyConvertible) -> String {
        let hostWithPath = self.appending(pathComponent)
        var urlComps = URLComponents(string: hostWithPath)!
        urlComps.queryItems = parameters.queryItems
        return urlComps.url?.absoluteString ?? ""
    }
}

extension String {
    var countryName: String? {
        let current = Locale.current
        return current.localizedString(forRegionCode: self)
    }
}

extension String {
    static func localized(_ key: String, table: String? = nil, bundle: Bundle = .main) -> String {
        NSLocalizedString(key, tableName: table, bundle: bundle, comment: "")
    }
}
