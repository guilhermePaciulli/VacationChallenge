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
    
    private init() {
        self.container = CKContainer.default()
        self.database = container.privateCloudDatabase
    }
    
    public func create(entity: NSManagedObject, completion: ((NSManagedObject?, CKCustomError?) -> (Void))?) {
        
    }
    
    
    
    
}

struct CKCustomError {
    let message: String
}
