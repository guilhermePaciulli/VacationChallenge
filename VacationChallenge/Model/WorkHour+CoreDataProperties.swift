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
    
    @nonobjc public class func startWorking(to task: Task) -> WorkHour {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "WorkHour",
                                                         into: DatabaseController.shared.persistentContainer.viewContext)
        let workHour = entity as! WorkHour
        workHour.started = NSDate()
        workHour.task = task
        DatabaseController.shared.saveContext()
        
        return workHour
    }
    
    public func updateWorkHour(by hour: Double) {
        self.task?.hoursWorked -= self.hoursSpent
        self.hoursSpent = hour
        self.finished = Calendar.current.date(byAdding: .hour,
                                                       value: Int(self.hoursSpent),
                                                       to: self.finished! as Date)! as NSDate
        self.task?.hoursWorked += self.hoursSpent
        DatabaseController.shared.saveContext()
    }
    
    public func stop() {
        if self.finished != nil { return }
        self.finished = NSDate()
        let calendar = Calendar.current
        let dateResults = calendar.dateComponents([.year, .month, .day, .hour, .minute],
                                                  from: self.started! as Date,
                                                  to: self.finished! as Date)
        self.hoursSpent = Double(dateResults.year!)  * 8.640 +
            Double(dateResults.month!) *   720 +
            Double(dateResults.day!)   *    24 +
            Double(dateResults.hour!)          +
            ((Double(dateResults.minute!)) / 60)
        self.hoursSpent = Double(round(self.hoursSpent * 100) / 100)
        self.task?.hoursWorked += self.hoursSpent
        self.task?.hoursWorked = Double(round((self.task?.hoursWorked)! * 100) / 100)
        DatabaseController.shared.saveContext()
    }
    
    public func delete() {
        self.task?.hoursWorked -= self.hoursSpent
        DatabaseController.shared.saveContext()
        DatabaseController.shared.persistentContainer.viewContext.delete(self)
        DatabaseController.shared.saveContext()
    }
    
    @NSManaged public var started: NSDate?
    @NSManaged public var finished: NSDate?
    @NSManaged public var hoursSpent: Double
    @NSManaged public var task: Task?
    
}
