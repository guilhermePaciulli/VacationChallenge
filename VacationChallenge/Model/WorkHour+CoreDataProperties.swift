//
//  WorkHour+CoreDataProperties.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 09/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//
//

import Foundation
import CoreData


extension WorkHour {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkHour> {
        return NSFetchRequest<WorkHour>(entityName: "WorkHour")
    }

    @NSManaged public var started: NSDate?
    @NSManaged public var finished: NSDate?
    @NSManaged public var hoursSpent: Double
    @NSManaged public var task: Task?

}
