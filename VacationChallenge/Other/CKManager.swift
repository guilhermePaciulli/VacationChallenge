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
    
    public func pullCloudToLocal(completion: @escaping ([Task]?, CKCustomError?) -> (Void)) {
        let query = CKQuery(recordType: self.TaskRecordType, predicate: NSPredicate(value: true))
        self.database.perform(query, inZoneWith: nil, completionHandler: {(taskRecords, error) in
            guard error == nil, let records = taskRecords else {
                completion(nil, CKCustomError(message: "Error in fetching tasks"))
                return
            }
            var diffTasks: [Task] = []
            var counter = records.count
            for taskRecord in records {
                if !Task.fetchBy(ckRecordId: taskRecord.recordID.recordName).isEmpty { continue }
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
                                    guard error == nil, let workHourRecord = workHourRecord else { return }
                                    if  let started = workHourRecord[.started] as? NSDate, let finished = workHourRecord[.finished] as? NSDate, let hoursSpent = workHourRecord[.hoursSpent] as? Double {
                                        
                                        if let workHour = NSEntityDescription.insertNewObject(forEntityName: "WorkHour", into: DatabaseController.shared.persistentContainer.viewContext) as? WorkHour {
                                            workHour.started = started
                                            workHour.finished = finished
                                            workHour.hoursSpent = hoursSpent
                                            workHour.ckRecordId = workHourRecord.recordID.recordName
                                            task.addToWorkHours(workHour)
                                        }
                                    }
                                    diffTasks.append(task)
                                    counter -= 1
                                    if counter == 0 {
                                        DatabaseController.shared.saveContext()
                                        completion(diffTasks, nil)
                                    }
                                })
                            }
                        } else {
                            diffTasks.append(task)
                            counter -= 1
                            if counter == 0 {
                                DatabaseController.shared.saveContext()
                                completion(diffTasks, nil)
                            }
                        }
                    }
                }
            }
        })
    }
    
    public func create(entity: NSManagedObject, completion: ((CKCustomError?) -> (Void))?) {
        switch entity {
        case is Task:
            self.create(task: entity as! Task, completion: { error in
                if completion != nil {
                    completion!(error)
                }
            })
        case is WorkHour:
            self.create(workHour: entity as! WorkHour, completion: { error in
                if completion != nil {
                    completion!(error)
                }
            })
        default:
            if completion != nil {
                completion!(CKCustomError(message: "Entity is not implemented on Cloud Kit"))
            }
        }
    }
    
    private func create(task: Task, completion: ((CKCustomError?) -> (Void))?) {
        let taskRecord = CKRecord(recordType: self.TaskRecordType)
        taskRecord[.title] = task.title
        taskRecord[.rating] = task.rating
        taskRecord[.hoursDeadline] = task.hoursDeadline
        taskRecord[.hoursWorked] = task.hoursWorked
        
        self.database.save(taskRecord, completionHandler: { (record, error) in
            guard let completion = completion else { return }
            if error != nil {
                completion(CKCustomError(message: "Error in creating new task record"))
            } else {
                task.ckRecordId = record?.recordID.recordName
                DatabaseController.shared.saveContext()
                completion(nil)
            }
        })
    }
    
    private func create(workHour: WorkHour, completion: ((CKCustomError?) -> (Void))?) {
        let record = CKRecord(recordType: self.WorkHourRecordType)
        record[.started] = workHour.started
        record[.finished] = workHour.finished
        record[.hoursSpent] = workHour.hoursSpent
        
        if let taskCKRecordID = workHour.task?.ckRecordId {
            self.database.fetch(withRecordID: CKRecordID(recordName: taskCKRecordID), completionHandler: { (taskRecord, error) in
                record[.task] = taskRecord
                self.database.save(record, completionHandler: { (record, error) in
                    guard let completion = completion else { return }
                    if error != nil {
                        completion(CKCustomError(message: "Error in creating new work hour record"))
                    } else {
                        workHour.ckRecordId = record?.recordID.recordName
                        DatabaseController.shared.saveContext()
                        completion(nil)
                    }
                })
            })
        }
    }
    
}

struct CKCustomError {
    let message: String
}
