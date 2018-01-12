//
//  NewTaskViewController.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 09/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//

import UIKit

class NewTaskViewController: UIViewController,  UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var taskTitleTextField: UITextField!
    
    @IBOutlet weak var deadlinePickerView: UIPickerView!
    
    var taskTableViewController: UITableViewController?
    
    let pickerValues = TaskDeadline.options
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = popUpView.frame.width / 20
        popUpView.clipsToBounds = true
        popUpView.layer.borderWidth = popUpView.frame.width / 400
        popUpView.layer.borderColor = #colorLiteral(red: 1, green: 0.2100759341, blue: 0.04853530163, alpha: 1)
        deadlinePickerView.delegate = self
        deadlinePickerView.dataSource = self
        taskTitleTextField.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func createButtonTapped(_ sender: UIButton) {
        
        if let taskTitle = self.taskTitleTextField.text {
            if taskTitle.isEmpty {
                self.taskTitleTextField.shake()
                return
            }
            let selectedTaskDeadline = self.pickerValues[self.deadlinePickerView.selectedRow(inComponent: 0)]
            Task.newTask(title: taskTitle, hoursDeadline: Double(selectedTaskDeadline.hours))
        } else {
            self.taskTitleTextField.shake()
            return
        }
        
        self.dismiss(animated: true, completion: {
            if let tasksTableViewController = self.taskTableViewController as? TasksTableViewController {
                tasksTableViewController.reloadTasks()
            }
        })
    }
    
}

extension NewTaskViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let taskTitle = self.taskTitleTextField.text {
            if taskTitle.count > 15 && string != "" {
                self.taskTitleTextField.shake()
                return false
            }
        }
        return true
    }
    
}

extension NewTaskViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerValues[row].title
    }
}
