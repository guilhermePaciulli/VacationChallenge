//
//  TasksTableViewController.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 09/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController {
    
    var continueTasks: [Task] = []
    
    var unbegunTasks: [Task] = []
    
    var begunTasks: [Task] = []
    
    var sections: [Sections] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTasks()
    }
    
    func reloadTasks() {
        self.continueTasks = []
        self.begunTasks = []
        self.unbegunTasks = []
        self.sections = []
        
        let allTasks = Task.fetchAll()
        for task in allTasks {
            if let workHours = task.workHours {
                if workHours.firstObject != nil {
                    if let lastWorkHour = workHours.lastObject as? WorkHour {
                        if lastWorkHour.finished == nil {
                            self.begunTasks.append(task)
                        } else {
                            self.continueTasks.append(task)
                        }
                    }
                } else {
                    self.unbegunTasks.append(task)
                }
            } else {
                self.unbegunTasks.append(task)
            }
        }
        if self.begunTasks.count > 0 { self.sections.append(.begunTasks) }
        if self.continueTasks.count > 0 { self.sections.append(.continueTasks) }
        if self.unbegunTasks.count > 0 { self.sections.append(.unbegunTasks) }

        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.sections[section] {
        case .begunTasks:
            return self.begunTasks.count
        case .continueTasks:
            return self.continueTasks.count
        case .unbegunTasks:
            return self.unbegunTasks.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].rawValue
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseIdentifier = ""
        var task: Task!
        switch self.sections[indexPath.section] {
        case .begunTasks:
            reuseIdentifier = "begunTaskCell"
            task = self.begunTasks[indexPath.row]
        case .continueTasks:
            reuseIdentifier = "continueTaskCell"
            task = self.continueTasks[indexPath.row]
        case .unbegunTasks:
            reuseIdentifier = "unbegunTaskCell"
            task = self.unbegunTasks[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let taskCell = cell as? TaskTableViewCell {
            taskCell.cellTask = task
            taskCell.taskCellTitle.text = task.title
            taskCell.tableViewController = self
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "singleTaskViewController") as? SingleTaskTableViewController {
            var task: Task!
            switch self.sections[indexPath.section] {
            case .begunTasks:
                task = self.begunTasks[indexPath.row]
            case .continueTasks:
                task = self.continueTasks[indexPath.row]
            case .unbegunTasks:
                task = self.unbegunTasks[indexPath.row]
            }
            viewController.task = task
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 2 || indexPath.section == 1
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}

extension TasksTableViewController {
    
    enum Sections: String {
        case begunTasks = "Active tasks"
        case unbegunTasks = "Tasks to be started"
        case continueTasks = "Tasks in progress"
    }
    
}
