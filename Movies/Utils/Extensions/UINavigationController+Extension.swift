//
//  UINavigationController+Extension.swift
//  Movies
//
//  Created by Dmytro Hetman on 27.01.2025.
//

import UIKit

extension UINavigationController {
    func showAlert(error: NetworkError) {
        let alert = UIAlertController(
            title: error.title,
            message: error.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: .localized(LocalizedKey.Title.ok), style: .default))
        self.topViewController?.present(alert, animated: true)
    }
}
