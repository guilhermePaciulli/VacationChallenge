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
}
