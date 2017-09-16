//
//  CoreDataManager.swift
//  ProximityReminders
//
//  Created by Ty Schenk on 09/13/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//


import Foundation
import CoreData
import CoreLocation

public class CoreDataManager {
    static let sharedInstance = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Reminders")
        container.loadPersistentStores(completionHandler: { storeDiscriptor, error in
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()

    lazy var fetchedResultsController: NSFetchedResultsController<Reminder> = {
        // Creating the request
        let fetchRequest: NSFetchRequest = Reminder.fetchRequest()
        // creating the sort descriptor: ordered by date
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        // adding hte sort descriptor to the request
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Creating the controller with: the request and the menaged context.
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    // Method to save the reminder
    func saveContext() {
        // If the menaged object context has any changes
        if self.managedObjectContext.hasChanges {
            do {
                // try to save
                try self.managedObjectContext.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        } else {
            print("Hey! What am I supposed to save again?")
        }
    }
    
    // Save the location
    func saveLocation(location: CLLocation) -> Location {
        
        // creating a new location
        let loc = Location(entity: Reminder.entity(), insertInto: self.managedObjectContext)
        
        loc.latitude = location.coordinate.latitude
        loc.longitude = location.coordinate.longitude
        
        return loc
    }
    
    // Delete Reminder
    func deleteReminder(reminder: Reminder) {
        
        // delete reminder
        managedObjectContext.delete(reminder)
        self.saveContext()
    }
}
