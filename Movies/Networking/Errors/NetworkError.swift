//
//  NetworkError.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import Foundation

enum NetworkError: Error, AlertError {
    case invalidAPIKey
    case noData
    case networkError(Int)
    case undefinedError
    case apiIssue
    case youAreOffline
}

extension NetworkError {
    var title: String {
        .localized(LocalizedKey.Title.error)
    }
    
    var message: String {
        switch self {
        case .invalidAPIKey:
            .localized(LocalizedKey.Message.invalidAPIKey)
        case .noData:
            .localized(LocalizedKey.Message.noData)
        case .networkError(let code):
            "\(String.localized(LocalizedKey.Message.networkError)) \(code)"
        case .undefinedError:
            .localized(LocalizedKey.Message.undefinedError)
        case .apiIssue:
            .localized(LocalizedKey.Message.apiIssue)
        case .youAreOffline:
            .localized(LocalizedKey.Message.offlineMode)
        }
    }
}
