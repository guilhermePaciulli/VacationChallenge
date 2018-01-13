//
//  EditWorkHourViewController.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 11/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//

import UIKit

class EditWorkHourViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var workHour: WorkHour!
    
    var tableView: SingleTaskTableViewController!
    
    @IBOutlet weak var hoursWorkedPicker: UIPickerView!
    
    @IBOutlet weak var popUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = popUpView.frame.width / 15
        popUpView.clipsToBounds = true
        popUpView.layer.borderWidth = popUpView.frame.width / 400
        popUpView.layer.borderColor = #colorLiteral(red: 1, green: 0.2100759341, blue: 0.04853530163, alpha: 1)
        hoursWorkedPicker.dataSource = self
        hoursWorkedPicker.delegate = self
    }
    @IBAction func setButtonTapped(_ sender: Any) {
        self.workHour.updateWorkHour(by: Double(self.hoursWorkedPicker.selectedRow(inComponent: 0)) + 1)
        self.dismiss(animated: true, completion: {
            self.tableView.reloadTaskOverview()
        })
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension EditWorkHourViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 8
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (row + 1) != 1 ? "\(row + 1) hours" : "1 hour"
    }
    
}
