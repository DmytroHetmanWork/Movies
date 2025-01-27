//
//  UIViewController+Extension.swift
//  Movies
//
//  Created by Dmytro Hetman on 27.01.2025.
//

import UIKit

extension UIViewController {
    func showAlert(error: AlertError, okAction: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .default) { _ in
            okAction?()
        }
        
        alertController.addAction(cancel)
    
        present(alertController, animated: true, completion: {
            guard let callback = completion else { return }
            DispatchQueue.main.async {
                callback()
            }
        })
    }
}
