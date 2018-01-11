//
//  Task+CoreDataProperties.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 09/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }
    
    @nonobjc public class func fetchAll() -> [Task] {
        do {
            let entities = try DatabaseController.shared.persistentContainer.viewContext.fetch(self.fetchRequest())
            if let tasks = entities as? [Task] {
                return tasks
            }
        } catch {
            fatalError("Failed to fetch beers: \(error)")
        }
        return []
    }
    
    @nonobjc public class func newTask(title: String, hoursDeadline: Double) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Task",
                                                         into: DatabaseController.shared.persistentContainer.viewContext)
        if let task = entity as? Task {
            task.title = title
            task.hoursDeadline = hoursDeadline
        }
        
        DatabaseController.shared.saveContext()

    }
    
    public func start() {
        if self.rating != 0 { return }
        if let last = self.workHours?.array.last as? WorkHour {
            if last.finished == nil { return }
        }
        self.addToWorkHours(WorkHour.startWorking(to: self))
        DatabaseController.shared.saveContext()
    }
    
    public func stop() {
        if self.rating != 0 { return }
        if let last = self.workHours?.array.last as? WorkHour {
            if last.finished != nil { return }
            last.stop()
            DatabaseController.shared.saveContext()
        }
    }
    
    public func complete() {
        if self.rating != 0 { return }
        self.stop()
        let diff = self.hoursWorked - self.hoursDeadline
        let grade = 10 / ((diff * diff) +  1)
        self.rating = Double(round(grade * 100) / 100)
    }

    @NSManaged public var title: String?
    @NSManaged public var hoursDeadline: Double
    @NSManaged public var rating: Double
    @NSManaged public var hoursWorked: Double
    @NSManaged public var workHours: NSOrderedSet?

}

// MARK: Generated accessors for workHours
extension Task {

    @objc(insertObject:inWorkHoursAtIndex:)
    @NSManaged public func insertIntoWorkHours(_ value: WorkHour, at idx: Int)

    @objc(removeObjectFromWorkHoursAtIndex:)
    @NSManaged public func removeFromWorkHours(at idx: Int)

    @objc(insertWorkHours:atIndexes:)
    @NSManaged public func insertIntoWorkHours(_ values: [WorkHour], at indexes: NSIndexSet)

    @objc(removeWorkHoursAtIndexes:)
    @NSManaged public func removeFromWorkHours(at indexes: NSIndexSet)

    @objc(replaceObjectInWorkHoursAtIndex:withObject:)
    @NSManaged public func replaceWorkHours(at idx: Int, with value: WorkHour)

    @objc(replaceWorkHoursAtIndexes:withWorkHours:)
    @NSManaged public func replaceWorkHours(at indexes: NSIndexSet, with values: [WorkHour])

    @objc(addWorkHoursObject:)
    @NSManaged public func addToWorkHours(_ value: WorkHour)

    @objc(removeWorkHoursObject:)
    @NSManaged public func removeFromWorkHours(_ value: WorkHour)

    @objc(addWorkHours:)
    @NSManaged public func addToWorkHours(_ values: NSOrderedSet)

    @objc(removeWorkHours:)
    @NSManaged public func removeFromWorkHours(_ values: NSOrderedSet)

}
