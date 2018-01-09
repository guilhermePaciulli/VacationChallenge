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
