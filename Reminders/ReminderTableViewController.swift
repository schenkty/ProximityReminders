//
//  ReminderTableViewController.swift
//  ProximityReminders
//
//  Created by Ty Schenk on 09/13/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import CoreData

class ReminderTableViewController: UITableViewController, writeLocationBackDelegate {

    var reminder: Reminder?
    let coreDataManager = CoreDataManager.sharedInstance
    let locationManager = LocationManager()
    var notificationManager = NotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    var location: CLLocation?
    var event: String?
    var eventBool: Bool?
    var newReminder: Bool = true
    var name: String?

    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var locationCell: UITableViewCell!
    @IBOutlet weak var locationSwitch: UISwitch!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable Hide keyboard method
        self.hideKeyboardWhenTappedAround()
        
        //Customise navigation bar
        if self.reminder != nil {
            navigationItem.title = "Details"
            newReminder = false
        } else {
            navigationItem.title = "New"
            newReminder = true
        }
        
        //Customise tableview
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //Set the text of the location cell
        locationCell.textLabel?.text = "Location"
        locationCell.detailTextLabel?.text = ""

    }
    
    // Try to setup before the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let reminder = self.reminder {
            self.reminderTextField.text = reminder.text
            
            if reminder.location != nil {
                locationCell.detailTextLabel?.text = "-"
                reverseLocation()
                
                locationSwitch.setOn(true, animated: false)
                locationCell.isHidden = false
            }
        } else {
            setupNewReminder()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.location = nil
    }
    
    @IBAction func toggleValueChanged(_ sender: UISwitch) {
        // This is a total wreck lmfao - gotta clean this up sometime
        if newReminder == true {
            showAlert(with: "Oops", andMessage: "You must enter a name for your reminder first")
            sender.setOn(false, animated: true)
        } else {
            if let reminder = self.reminder {
                if sender.isOn {
                    sender.setOn(false, animated: true)
                    locationCell.isHidden = true
                    reminder.location = nil
                    notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminder.identifier!])
                    
                    // Update Reminder
                    coreDataManager.saveContext()
                }else {
                    sender.setOn(true, animated: true)
                    locationCell.isHidden = false
                }
            }
        }
    }
    
    func setupNewReminder() {
        // Adding a notification observer for typing inside the textfield
        NotificationCenter.default.addObserver(forName: Notification.Name.UITextFieldTextDidChange, object: reminderTextField, queue: OperationQueue.main, using: { (notification) in
            
            // Check if reminder is empty and if this is a new reminder
            if self.reminderTextField.text != "" && self.newReminder == true {
                self.newReminder = false
                self.reminder = Reminder(entity: Reminder.entity(), insertInto: self.coreDataManager.managedObjectContext)
                self.reminder?.text = self.reminderTextField.text!
                self.reminder?.date = NSDate()
                self.reminder?.identifier = String(describing: Date())
                self.coreDataManager.saveContext()
            } else if self.reminderTextField.text != "" && self.newReminder == false {
                self.newReminder = false
                self.reminder?.text = self.reminderTextField.text
                self.coreDataManager.saveContext()
            }
        })
    }
    
    func saveReminder() {
        if let reminder = self.reminder, let location = self.location, let name = self.name {
            
            let locationToSave = Location(entity: Location.entity(), insertInto: coreDataManager.managedObjectContext)
            
            locationToSave.latitude = location.coordinate.latitude
            locationToSave.longitude = location.coordinate.longitude
            locationToSave.event = self.event
            
            reminder.name = name
            reminder.location = locationToSave
            
            coreDataManager.saveContext()
        }
    }
    
    func writeLocationBack(toLocation: CLLocation, event: String, name: String) {
        
        self.location = toLocation
        self.event = event
        self.name = name
        
        saveReminder()
        
        locationCell.detailTextLabel?.text = "-"
        reverseLocation()
        
        if event == "Leaving" {
            eventBool = true
        }else {
            eventBool = false
        }
        
        if let reminder = self.reminder, let eventBool = self.eventBool {
            
            let locationEvent = notificationManager.addLocationEvent(forReminder: reminder, whenLeaving: eventBool)
            notificationManager.scheduleNewNotification(withReminder: reminder, locationTrigger: locationEvent)
        }
    }
    
    func reverseLocation() {
        
        if let locationToReverse = reminder?.location, let event = reminder?.location?.event, let name = reminder?.name {
            
            locationManager.reverseLocation(location: locationToReverse) { (city, street) in
                
                self.locationCell.detailTextLabel?.text = "\(event): \(name), \(street), \(city)"
            }
        }
    }
    
    // Table view methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 && indexPath.row == 1 {
            performSegue(withIdentifier: "SearchLocationView", sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 && indexPath.row == 1 {
            
            return 64.0
        }
        
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SearchLocationView" {
            
            let searchVC = segue.destination as! SearchTableViewController
            
            if let reminder = self.reminder {
                
                searchVC.reminder = reminder
                searchVC.delegate = self
            }
        }
    }
    
}
