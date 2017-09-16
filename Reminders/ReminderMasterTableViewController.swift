//
//  ReminderMasterTableViewController.swift
//  ProximityReminders
//
//  Created by Ty Schenk on 09/13/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ReminderMasterTableViewController: UITableViewController {
    
    let coreDataManager = CoreDataManager.sharedInstance
    var selectedReminder: Reminder?
    let notificationCenter = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreDataManager.fetchedResultsController.delegate = self
        
        //Fetch the results from the database
        fetchResults()
    }
    
    //Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Number of rows per sections
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // If there are remminders
        if let reminders = coreDataManager.fetchedResultsController.fetchedObjects?.count {
            return reminders
        } else {
            return 1
        }
    }
    
    // Setting the cell for each row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create a cell with id: Reminder Cell of type ReminderTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderTableViewCell
        // Retrieve the reminder at position indexPath
        let reminder = coreDataManager.fetchedResultsController.object(at: indexPath)
        
        // Configure the cell with the reminder
        cell.configure(withReminder: reminder)
        
        return cell
    }
    
    // If a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // retrivng the selected reminder
        selectedReminder = coreDataManager.fetchedResultsController.object(at: indexPath)
        
        // performing the segue to the DetailTableViewController
        performSegue(withIdentifier: "ReminderDetail", sender: self)
    }
    
    // The possible edit actions for row at indexPath
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) ->
        
        [UITableViewRowAction]? {
            
            // Set the delete action
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
                
                let reminder = self.coreDataManager.fetchedResultsController.object(at: indexPath)
                
                if let _ = reminder.location, let identifier = reminder.identifier {
                    // remove the pending notification for the current reminder
                    self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                }
                
                // delete the reminder from the database
                self.coreDataManager.deleteReminder(reminder: reminder)
            }
            
            // Set the complete action
            let complete = UITableViewRowAction(style: .normal, title: "Completed") { action, indexPath in
                
                let reminder = self.coreDataManager.fetchedResultsController.object(at: indexPath)
                reminder.isCompleted = true
                
                if let _ = reminder.location, let identifier = reminder.identifier {
                    self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                    self.notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
                }
                
                self.coreDataManager.saveContext()
            }
            
            // Set the incomplete action
            let incomplete = UITableViewRowAction(style: .normal, title: "Incompleted") { action, indexPath in
                
                let reminder = self.coreDataManager.fetchedResultsController.object(at: indexPath)
                reminder.isCompleted = false
                self.coreDataManager.saveContext()
            }
            
            let reminder = self.coreDataManager.fetchedResultsController.object(at: indexPath)
            
            if reminder.isCompleted {
                //Show:
                return [delete, incomplete]
            } else {
                //Show
                return [delete, complete]
            }
    }
    
    // Fetch the results from the CoreData Database
    func fetchResults() {
        
        do {
            // try to perform the fetch
            try coreDataManager.fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            showAlert(with: "Error", andMessage: "\(error.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ReminderDetail" {
            
            let reminderVC = segue.destination as! ReminderTableViewController
            
            reminderVC.reminder = selectedReminder
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension ReminderMasterTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // if the content change, reload the data of the table.
        self.tableView.reloadData()
    }
}
