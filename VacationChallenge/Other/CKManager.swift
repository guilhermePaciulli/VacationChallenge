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
    
    private init() {
        self.container = CKContainer.default()
        self.database = container.privateCloudDatabase
    }
    
    public func pullCloudToLocal(completion: @escaping () -> (Void)) {
        let query = CKQuery(recordType: self.TaskRecordType, predicate: NSPredicate(value: true))
        self.database.perform(query, inZoneWith: nil, completionHandler: { (taskRecords, error) in
            guard error == nil, let records = taskRecords else {
                completion()
                return
            }
            var counter = records.count
            for taskRecord in records {
                if let localTask = Task.fetchBy(ckRecordId: taskRecord.recordID.recordName).first {
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
    
    private func compare(record: CKRecord, to task: Task) -> Bool {
        if  let title = record[.title] as? String,
            let hoursDeadline = record[.hoursDeadline] as? Double,
            let rating = record[.rating] as? Double,
            let hoursWorked = record[.hoursWorked] as? Double {
            return title == task.title &&
                hoursWorked == task.hoursWorked &&
                rating == task.rating &&
                hoursDeadline == task.hoursDeadline
        }
        return false
    }
    
    private func compare(record: CKRecord, to workHour: WorkHour) -> Bool {
        if  let started = record[.started] as? NSDate,
            let finished = record[.finished] as? NSDate,
            let hoursSpent = record[.hoursSpent] as? Double {
            return started == workHour.started &&
                finished == workHour.finished &&
                hoursSpent == workHour.hoursSpent
        }
        return false
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
            guard error == nil, let taskRecord = record else { return }
            taskRecord[.title] = task.title
            taskRecord[.rating] = task.rating
            taskRecord[.hoursDeadline] = task.hoursDeadline
            taskRecord[.hoursWorked] = task.hoursWorked
            self.database.save(taskRecord, completionHandler: { (_, _) in })
        })
    }
    
    private func update(workHour: WorkHour, recordName: String) {
        self.database.fetch(withRecordID: CKRecordID(recordName: recordName), completionHandler:{ (record, error) in
            guard error == nil, let workHourRecord = record else { return }
            workHourRecord[.started] = workHour.started
            workHourRecord[.finished] = workHour.finished
            workHourRecord[.hoursSpent] = workHour.hoursSpent
            self.database.save(workHourRecord, completionHandler: { (_, _) in })
        })
    }
    
    public func delete(entity: NSManagedObject) {
        switch entity {
        case is Task:
            let task = entity as! Task
            if let recordName = task.ckRecordId {
                self.database.delete(withRecordID: CKRecordID(recordName: recordName), completionHandler: { (_, _) in })
            }
        case is WorkHour:
            let workHour = entity as! WorkHour
            if let recordName = workHour.ckRecordId {
                self.database.delete(withRecordID: CKRecordID(recordName: recordName), completionHandler: { (_, _) in })
            }
        default:
            break
        }
    }
    
}
