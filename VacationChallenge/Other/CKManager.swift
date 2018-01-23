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
    
    private let task = "Task"
    private let workHour = "WorkHour"
    
    private init() {
        self.container = CKContainer.default()
        self.database = container.privateCloudDatabase
    }
    
    public func fetchTasks(completion: @escaping (CKCustomError) -> (Void)) {
        let query = CKQuery(recordType: self.task, predicate: NSPredicate(value: true))
        self.database.perform(query, inZoneWith: nil, completionHandler: {(records, error) in
            guard error == nil else {
                completion(CKCustomError(message: "Error in fetching tasks"))
                return
            }
            if let records = records {
                for record in records {
                    if  let title = record[.title] as? String,
                        let hoursDeadline = record[.hoursDeadline],
                        let rating = record[.rating],
                        let hoursWorked = record[.hoursWorked],
                        let workHours = record[.workHours] {
                        
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
        let record = CKRecord(recordType: self.task)
        record[.title] = task.title
        record[.rating] = task.rating
        record[.hoursDeadline] = task.hoursDeadline
        record[.workHours] = task.workHours
        record[.hoursWorked] = task.hoursWorked
        self.database.save(record, completionHandler: { (record, error) in
            guard let completion = completion else { return }
            if error != nil {
                completion(CKCustomError(message: "Error in creating new task record"))
            } else {
                completion(nil)
            }
        })
    }
    
    private func create(workHour: WorkHour, completion: ((CKCustomError?) -> (Void))?) {
        let record = CKRecord(recordType: self.workHour)
        record[.started] = workHour.started
        record[.finished] = workHour.finished
        record[.hoursSpent] = workHour.hoursSpent
        record[.task] = workHour.task
        self.database.save(record, completionHandler: { (record, error) in
            guard let completion = completion else { return }
            if error != nil {
                completion(CKCustomError(message: "Error in creating new work hour record"))
            } else {
                completion(nil)
            }
        })
    }
    
    
}

struct CKCustomError {
    let message: String
}
