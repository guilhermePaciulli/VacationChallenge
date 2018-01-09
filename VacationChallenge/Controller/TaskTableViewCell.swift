//
//  TaskTableViewCell.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 09/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    var cellTask: Task?
    
    var tableViewController: UITableViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                             action: #selector(completeTask))
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func stopTask(_ sender: UIButton) {
        tableViewController?.tableView.reloadData()
    }
    
    @IBAction func startTask(_ sender: UIButton) {
        tableViewController?.tableView.reloadData()
    }
    
    @IBAction func continueTask(_ sender: UIButton) {
        tableViewController?.tableView.reloadData()
    }
    
    @objc func completeTask() {
        tableViewController?.tableView.reloadData()
    }
}
