//
//  TaskTableViewCell.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 09/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    var cellTask: Task!
    
    var tableViewController: TasksTableViewController!

    @IBOutlet weak var continueButtonOutlet: UIButton!
    
    @IBOutlet weak var taskCellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                             action: #selector(completeTask))
        self.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func stopTask(_ sender: UIButton) {
        self.cellTask.stop()
        tableViewController.reloadTasks()
    }
    
    @IBAction func startTask(_ sender: UIButton) {
        self.cellTask.start()
        tableViewController.reloadTasks()
    }
    
    @IBAction func continueTask(_ sender: UIButton) {
        self.cellTask.start()
        tableViewController.reloadTasks()
    }
    
    @objc func completeTask() {
        self.cellTask.complete()
        tableViewController.reloadTasks()
    }
}
