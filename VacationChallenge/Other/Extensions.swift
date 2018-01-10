//
//  Extensions.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 09/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewController {
    
    func displayEmpty(message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: self.view.bounds.width,
                                                 height: self.view.bounds.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.blue
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = .none;
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension String {
    public func isValid() -> Bool {
        return !(self.isEmpty || self.trimmingCharacters(in: .whitespaces).isEmpty)
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, alpha: Double) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
    
}
