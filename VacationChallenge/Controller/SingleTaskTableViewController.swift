//
//  SingleTaskTableViewController.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 10/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//

import UIKit

class SingleTaskTableViewController: UITableViewController {
    
    var task: Task!
    
    var workHours: [WorkHour] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.task.title
        if self.task.rating == 0 {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                                     style: .plain,
                                                                     target: self,
                                                                     action: #selector(editWorkHours))
        }
        self.reloadTaskOverview()
    }
    
    public func reloadTaskOverview() {
        self.workHours = self.task.workHours?.array as! [WorkHour]
        self.workHours.reverse()
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Task overview"
        }
        return "Task entry log"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        return self.workHours.count == 0 ? 1 : self.workHours.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseId = ""
        
        if indexPath.section == 1 {
            reuseId = "workHourCell"
        } else {
            if indexPath.row == 0 {
                reuseId = "totalTimeSpentCell"
            } else if indexPath.row == 1 {
                reuseId = "estimatedTimeCell"
            } else if indexPath.row == 2 {
                if self.task.rating == 0 {
                    reuseId = "taskGradeCell"
                } else {
                    reuseId = self.task.isActive() ? "stopActionsCell" : "startActionsCell"
                }
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId,
                                                 for: indexPath)
        
        if indexPath.section == 1 {
            
            if self.workHours.count == 0 {
                cell.textLabel?.text = "Task not yet started!"
                cell.detailTextLabel?.text = ""
                return cell
            }
            
            let workHour = self.workHours[indexPath.row]
            cell.textLabel?.text = String(describing: (workHour.hoursSpent * 100) / 100) + " Hours"
            if let workHourFinishedDate = workHour.finished {
                let components = Calendar.current.dateComponents([.day, .month, .hour, .minute], from: workHourFinishedDate as Date)
                let stringDay = String(describing: components.day!)
                let stringMonth = String(describing: components.month!)
                let stringMinute = String(describing: components.minute!)
                let stringHour = String(describing: components.hour!)
                cell.detailTextLabel?.text = "at "+stringHour+":"+stringMinute+" of "+stringMonth+"/"+stringDay
            } else {
                cell.detailTextLabel?.text = "Running!"
                cell.detailTextLabel?.textColor = UIColor.init(red: 30, green: 189, blue: 30, alpha: 1)
            }
        } else {
            if indexPath.row == 0 {
                cell.detailTextLabel?.text = String(describing: (task.hoursWorked * 100) / 100) + " Hours"
            } else if indexPath.row == 1 {
                cell.detailTextLabel?.text = String(describing: (task.hoursDeadline * 100) / 100) + " Hours"
            } else if indexPath.row == 2 && self.task.rating != 0 {
                var rating = String(describing: (task.rating * 100) / 100)
                var ratingColor = UIColor.black
                if task.rating < 6 {
                    rating += "You need to improve"
                    ratingColor = UIColor.init(red: 214, green: 13, blue: 13, alpha: 1)
                } else if task.rating < 8 {
                    rating += "Good! But you can do better"
                    ratingColor = UIColor.init(red: 224, green: 224, blue: 7, alpha: 1)
                } else {
                    rating += "Awesome! Keep up the good work"
                    ratingColor = UIColor.init(red: 30, green: 189, blue: 30, alpha: 1)
                }
                cell.detailTextLabel?.text = rating
                cell.detailTextLabel?.textColor = ratingColor
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let workHourToBeDeleted = self.workHours[indexPath.row]
            self.workHours.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            workHourToBeDeleted.delete()
            self.reloadTaskOverview()
        }
    }
    
    @objc func editWorkHours() {
        self.tableView.isEditing = !self.tableView.isEditing
    }
    
    @IBAction func startStopTask(_ sender: Any) {
        if self.task.isActive() {
            self.task.stop()
        } else {
            self.task.start()
        }
        self.reloadTaskOverview()
    }
    
    @IBAction func completeTask(_ sender: Any) {
        self.task.complete()
        self.reloadTaskOverview()
    }
}
