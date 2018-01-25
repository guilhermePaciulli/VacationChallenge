//
//  Task+CoreDataProperties.swift
//  VacationChallenge
//
//  Created by Guilherme Paciulli on 23/01/18.
//  Copyright © 2018 Guilherme Paciulli. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }
    
    @nonobjc public class func fetchRequest(by ckRecordID: String) -> NSFetchRequest<Task> {
        let request = NSFetchRequest<Task>(entityName: "Task")
        request.predicate = NSPredicate(format: "ckRecordId = %@", ckRecordID)
        return request
    }
    
    @nonobjc public class func fetchAll() -> [Task] {
        do {
            let entities = try DatabaseController.shared.persistentContainer.viewContext.fetch(self.fetchRequest())
            if let tasks = entities as? [Task] {
                return tasks
            }
        } catch {
            fatalError("Failed to fetch tasks: \(error)")
        }
        return []
    }
    
    @nonobjc public class func fetchBy(ckRecordId: String) -> [Task] {
        do {
            let entities = try DatabaseController.shared.persistentContainer.viewContext.fetch(self.fetchRequest(by: ckRecordId))
            return entities as [Task]
        } catch {
            fatalError("Failed to fetch tasks: \(error)")
        }
        return []
    }
    
    @nonobjc public class func newTask(title: String, hoursDeadline: Double) {
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Task",
                                                         into: DatabaseController.shared.persistentContainer.viewContext)
        if let task = entity as? Task {
            task.title = title
            task.hoursDeadline = hoursDeadline
            task.rating = -1
        }
        
        CKManager.shared.create(entity: entity)
        
        DatabaseController.shared.saveContext()
        
    }
    
    public func start() {
        if self.isComplete() { return }
        if let last = self.workHours?.array.last as? WorkHour {
            if last.finished == nil { return }
        }
        self.addToWorkHours(WorkHour.startWorking(to: self))
        DatabaseController.shared.saveContext()
        CKManager.shared.update(entity: self)
    }
    
    public func stop() {
        if self.isComplete() { return }
        if let last = self.workHours?.array.last as? WorkHour {
            if last.finished != nil { return }
            last.stop()
            DatabaseController.shared.saveContext()
        }
    }
    
    public func hasStarted() -> Bool {
        if let workHours = self.workHours?.array {
            return !workHours.isEmpty
        }
        return false
    }
    
    public func isActive() -> Bool {
        if !hasStarted() { return false }
        if let last = self.workHours?.array.last as? WorkHour {
            return last.finished == nil
        }
        return false
    }
    
    public func isComplete() -> Bool {
        return self.rating != -1
    }
    
    public func complete() {
        if self.isComplete() { return }
        self.stop()
        var escaled = (10 * self.hoursWorked) / self.hoursDeadline
        escaled = escaled - 10
        escaled = escaled < 0 ? -1 * escaled : escaled
        escaled = (-1 * escaled) + 10
        escaled = escaled < 0 ? 0 : escaled
        self.rating = Double(round(escaled * 100)) / 100
        DatabaseController.shared.saveContext()
        CKManager.shared.update(entity: self)
    }
    
    public func delete() {
        if let workHours = (self.workHours?.array) as? [WorkHour] {
            for workHour in workHours {
                DatabaseController.shared.persistentContainer.viewContext.delete(workHour)
                CKManager.shared.delete(entity: workHour)
            }
        }
        DatabaseController.shared.persistentContainer.viewContext.delete(self)
        CKManager.shared.delete(entity: self)
        DatabaseController.shared.saveContext()
    }

    @NSManaged public var hoursDeadline: Double
    @NSManaged public var hoursWorked: Double
    @NSManaged public var rating: Double
    @NSManaged public var title: String?
    @NSManaged public var ckRecordId: String?
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
