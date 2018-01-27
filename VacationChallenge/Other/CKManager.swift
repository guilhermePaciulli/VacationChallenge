//
//  CKManager.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 22/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//

import Foundation
import CloudKit
import CoreData
import UIKit

class CKManager {
    
    static let shared = CKManager()
    
    private let container: CKContainer
    
    private let database: CKDatabase
    
    private let TaskRecordType = "Task"
    
    private let WorkHourRecordType = "WorkHour"
    
    private let tasksToBeDeleted = "tasksToBeDeletedKey"
    
    private let workHoursToBeDeleted = "workHoursToBeDeletedKey"
    
    private init() {
        self.container = CKContainer.default()
        self.database = container.privateCloudDatabase
    }
    
    public func pushToCloud() {
        for task in Task.fetchAll() {
            if task.ckRecordId != nil {
                if !task.cloudUpdated {
                    self.update(entity: task)
                }
                (task.workHours?.array as? [WorkHour])?.filter({ !$0.cloudUpdated }).forEach({ self.update(entity: $0) })
            } else {
                self.create(task: task)
            }
        }
        (UserDefaults.standard.array(forKey: self.tasksToBeDeleted) as? [String])?.forEach({ self.delete(taskWith: $0) })
        (UserDefaults.standard.array(forKey: self.workHoursToBeDeleted) as? [String])?.forEach({ self.delete(workHourWith: $0) })
    }
    
    public func pullFromCloud(completion: @escaping () -> (Void)) {
        let query = CKQuery(recordType: self.TaskRecordType, predicate: NSPredicate(value: true))
        self.database.perform(query, inZoneWith: nil, completionHandler: { (taskRecords, error) in
            guard error == nil, let records = taskRecords else {
                completion()
                return
            }
            var counter = records.count
            for taskRecord in records {
                if Task.fetchBy(ckRecordId: taskRecord.recordID.recordName).first != nil {
                    counter -= 1
                    if counter == 0 {
                        DatabaseController.shared.saveContext()
                        completion()
                    }
                    continue
                }
                if  let title = taskRecord[.title] as? String, let hoursDeadline = taskRecord[.hoursDeadline] as? Double, let rating = taskRecord[.rating] as? Double, let hoursWorked = taskRecord[.hoursWorked] as? Double {
                    
                    if let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: DatabaseController.shared.persistentContainer.viewContext) as? Task {
                        task.title = title
                        task.hoursDeadline = hoursDeadline
                        task.rating = rating
                        task.hoursWorked = hoursWorked
                        task.ckRecordId = taskRecord.recordID.recordName
                        
                        if let references = taskRecord[.workHours] as? [CKReference] {
                            for ref in references {
                                self.database.fetch(withRecordID: ref.recordID, completionHandler: { (workHourRecord, error) in
                                    guard error == nil, let workHourRecord = workHourRecord else {
                                        counter -= 1
                                        if counter == 0 {
                                            DatabaseController.shared.saveContext()
                                            completion()
                                        }
                                        return
                                    }
                                        
                                    if let workHour = NSEntityDescription.insertNewObject(forEntityName: "WorkHour", into: DatabaseController.shared.persistentContainer.viewContext) as? WorkHour {
                                        workHour.started = workHourRecord[.started] as? NSDate
                                        workHour.finished = workHourRecord[.finished] as? NSDate
                                        if let hoursSpent = workHourRecord[.hoursSpent] as? Double {
                                            workHour.hoursSpent = hoursSpent
                                        }
                                        workHour.ckRecordId = workHourRecord.recordID.recordName
                                        task.addToWorkHours(workHour)
                                    }
                                    counter -= 1
                                    if counter == 0 {
                                        DatabaseController.shared.saveContext()
                                        completion()
                                    }
                                })
                            }
                        } else {
                            counter -= 1
                            if counter == 0 {
                                DatabaseController.shared.saveContext()
                                completion()
                            }
                        }
                    }
                }
            }
        })
    }
    
    public func create(entity: NSManagedObject) {
        switch entity {
        case is Task:
            self.create(task: entity as! Task)
        case is WorkHour:
            self.create(workHour: entity as! WorkHour)
        default:
            break
        }
    }
    
    
    private func create(task: Task) {
        let taskRecord = CKRecord(recordType: self.TaskRecordType)
        taskRecord[.title] = task.title
        taskRecord[.rating] = task.rating
        taskRecord[.hoursDeadline] = task.hoursDeadline
        taskRecord[.hoursWorked] = task.hoursWorked
        
        self.database.save(taskRecord, completionHandler: { (record, error) in
            if error == nil {
                task.ckRecordId = record?.recordID.recordName
                task.cloudUpdated = true
                DatabaseController.shared.saveContext()
            }
        })
    }
    
    private func create(workHour: WorkHour) {
        let workHourRecord = CKRecord(recordType: self.WorkHourRecordType)
        workHourRecord[.started] = workHour.started
        workHourRecord[.finished] = workHour.finished
        workHourRecord[.hoursSpent] = workHour.hoursSpent
        
        if let taskCKRecordID = workHour.task?.ckRecordId {
            self.database.fetch(withRecordID: CKRecordID(recordName: taskCKRecordID), completionHandler: { (taskRecord, error) in
                workHourRecord[.task] = CKReference(record: taskRecord!, action: .deleteSelf)
                self.database.save(workHourRecord, completionHandler: { (record, error) in
                    
                    var workHourReference: [CKReference] = (taskRecord![.workHours] as? [CKReference]) ?? []
                    workHourReference.append(CKReference(record: record!, action: .none))
                    taskRecord![.workHours] = workHourReference
                    
                    self.database.save(taskRecord!, completionHandler: { (_, err) in
                        if err == nil && error == nil {
                            workHour.ckRecordId = record?.recordID.recordName
                            workHour.cloudUpdated = true
                            DatabaseController.shared.saveContext()
                        }
                    })
                })
            })
        }
    }
    
    public func update(entity: NSManagedObject) {
        switch entity {
        case is Task:
            let task = entity as! Task
            if let recordName = task.ckRecordId {
                self.update(task: task, recordName: recordName)
            } else {
                self.create(entity: task)
            }
        case is WorkHour:
            let workHour = entity as! WorkHour
            if let recordName = workHour.ckRecordId {
                self.update(workHour: workHour, recordName: recordName)
            } else {
                self.create(entity: workHour)
            }
        default:
            break
        }
    }
    
    private func update(task: Task, recordName: String) {
        self.database.fetch(withRecordID: CKRecordID(recordName: recordName), completionHandler:{ (record, error) in
            guard error == nil, let taskRecord = record else {
                task.cloudUpdated = false
                DatabaseController.shared.saveContext()
                return
            }
            taskRecord[.title] = task.title
            taskRecord[.rating] = task.rating
            taskRecord[.hoursDeadline] = task.hoursDeadline
            taskRecord[.hoursWorked] = task.hoursWorked
            self.database.save(taskRecord, completionHandler: { (_, error) in
                if error != nil {
                    task.cloudUpdated = false
                    DatabaseController.shared.saveContext()
                } else {
                    task.cloudUpdated = true
                    DatabaseController.shared.saveContext()
                }
            })
        })
    }
    
    private func update(workHour: WorkHour, recordName: String) {
        self.database.fetch(withRecordID: CKRecordID(recordName: recordName), completionHandler:{ (record, error) in
            guard error == nil, let workHourRecord = record else {
                workHour.cloudUpdated = false
                DatabaseController.shared.saveContext()
                return
            }
            workHourRecord[.started] = workHour.started
            workHourRecord[.finished] = workHour.finished
            workHourRecord[.hoursSpent] = workHour.hoursSpent
            self.database.save(workHourRecord, completionHandler: { (_, error) in
                if error != nil {
                    workHour.cloudUpdated = false
                    DatabaseController.shared.saveContext()
                } else {
                    workHour.cloudUpdated = true
                    DatabaseController.shared.saveContext()
                }
            })
        })
    }
    
    private func delete(taskWith ckRecordID: String) {
        self.database.delete(withRecordID: CKRecordID(recordName: ckRecordID), completionHandler: { (_, error) in
            if error != nil {
                if var toBeDeleted = UserDefaults.standard.array(forKey: self.tasksToBeDeleted) as? [String] {
                    toBeDeleted.append(ckRecordID)
                    UserDefaults.standard.set(toBeDeleted, forKey: self.tasksToBeDeleted)
                } else {
                    UserDefaults.standard.set([ckRecordID], forKey: self.tasksToBeDeleted)
                }
            } else {
                if let toBeDeleted = UserDefaults.standard.array(forKey: self.tasksToBeDeleted) as? [String] {
                    UserDefaults.standard.set(toBeDeleted.filter({ $0 != ckRecordID }), forKey: self.tasksToBeDeleted)
                }
            }
        })
    }
    
    private func delete(workHourWith ckRecordID: String) {
        self.database.delete(withRecordID: CKRecordID(recordName: ckRecordID), completionHandler: { (_, error) in
            if error != nil {
                if var toBeDeleted = UserDefaults.standard.array(forKey: self.workHoursToBeDeleted) as? [String] {
                    toBeDeleted.append(ckRecordID)
                    UserDefaults.standard.set(toBeDeleted, forKey: self.workHoursToBeDeleted)
                } else {
                    UserDefaults.standard.set([ckRecordID], forKey: self.workHoursToBeDeleted)
                }
            } else {
                if let toBeDeleted = UserDefaults.standard.array(forKey: self.workHoursToBeDeleted) as? [String] {
                    UserDefaults.standard.set(toBeDeleted.filter({ $0 != ckRecordID }), forKey: self.workHoursToBeDeleted)
                }
            }
        })
    }
    
    public func delete(entity: NSManagedObject) {
        switch entity {
        case is Task:
            let task = entity as! Task
            if let recordName = task.ckRecordId {
                self.delete(taskWith: recordName)
            }
        case is WorkHour:
            let workHour = entity as! WorkHour
            if let recordName = workHour.ckRecordId {
                self.delete(workHourWith: recordName)
            }
        default:
            break
        }
    }
    
}
