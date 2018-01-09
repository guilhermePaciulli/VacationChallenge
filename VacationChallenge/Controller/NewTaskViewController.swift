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
    
    let pickerValues =  [TaskDeadlinePickerValue(title: "1 hour",  hours: 1),
                         TaskDeadlinePickerValue(title: "2 hours", hours: 2),
                         TaskDeadlinePickerValue(title: "3 hours", hours: 3),
                         TaskDeadlinePickerValue(title: "4 hours", hours: 4),
                         TaskDeadlinePickerValue(title: "5 hours", hours: 5),
                         TaskDeadlinePickerValue(title: "6 hours", hours: 6),
                         TaskDeadlinePickerValue(title: "7 hours", hours: 7),
                         TaskDeadlinePickerValue(title: "1 day (8 hours)",   hours: 8),
                         TaskDeadlinePickerValue(title: "2 days (16 hours)", hours: 16),
                         TaskDeadlinePickerValue(title: "3 days (24 hours)", hours: 24),
                         TaskDeadlinePickerValue(title: "4 days (32 hours)", hours: 32),
                         TaskDeadlinePickerValue(title: "1 week (40 hours)",  hours: 40),
                         TaskDeadlinePickerValue(title: "2 weeks (80 hours)", hours: 80)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = popUpView.frame.width / 20
        popUpView.clipsToBounds = true
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
//            Create Task Here
        } else {
            self.taskTitleTextField.shake()
            return
        }
        
        self.dismiss(animated: true, completion: {
            self.taskTableViewController?.tableView.reloadData()
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
    
    struct TaskDeadlinePickerValue {
        var title: String
        var hours: Int
    }
}
