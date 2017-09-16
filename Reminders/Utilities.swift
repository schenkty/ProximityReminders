//
//  Utilities.swift
//  ProximityReminders
//
//  Created by Ty Schenk on 09/13/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import MapKit

extension UIViewController {
    
    // Show alert with a title and message
    func showAlert(with title: String, andMessage message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Setup method to hide keyboard when you tap anywhere other than the keyboard
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UINavigationController {
    
    private func doAfterAnimatingTransition(_ animated: Bool, completion: @escaping (() -> Void)) {
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil, completion: { _ in
                completion()
            })
        } else {
            OperationQueue.main.addOperation {
                completion()
            }
        }
    }
    
    func popToRootViewControllerAnimated(animated: Bool, completion: @escaping (() -> Void)) {
        popToRootViewController(animated: animated)
        doAfterAnimatingTransition(animated, completion: completion)
    }
}
