//
//  CloudKitEntityKeys.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 22/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//

import Foundation
import CloudKit

enum TaskKey: String {
    case title
    case hoursDeadline
    case rating
    case hoursWorked
    case workHours
}

enum WorkHourKey: String {
    case started
    case finished
    case hoursSpent
    case task
}

extension CKRecord {
    
    subscript(key: TaskKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? CKRecordValue
        }
    }
    
    subscript(key: WorkHourKey) -> Any? {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue as? CKRecordValue
        }
    }
    
}
