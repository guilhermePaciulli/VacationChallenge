//
//  ResultsTableViewController.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 11/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//

import UIKit

class ResultsTableViewController: UITableViewController {
    
    var completedTasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTasks()
    }
    
    public func reloadTasks() {
        self.completedTasks = Task.fetchAll().filter({ $0.isComplete() })
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.completedTasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.completedTasks[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = self.completedTasks[indexPath.row]
            self.completedTasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            DatabaseController.shared.persistentContainer.viewContext.delete(task)
            DatabaseController.shared.saveContext()
            self.reloadTasks()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "singleTaskViewController") as? SingleTaskTableViewController {
            viewController.task = self.completedTasks[indexPath.row]
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
