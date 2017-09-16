//
//  ReminderNewViewController.swift
//  ProximityReminders
//
//  Created by Andrea Miotto on 06/03/17.
//  Copyright © 2017 Andrea Miotto. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class ReminderNewViewController: UITableViewController, writeLocationBackDelegate {
    
    //---------------------
    //MARK: Variables
    //---------------------
    var reminder: Reminder?
    let coreDataManager = CoreDataManager.sharedInstance
    let locationManager = LocationManager()
    var notificationManager = NotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    var location: CLLocation?
    var event: String?
    var eventBool: Bool?
    
    //---------------------
    //MARK: Outlets
    //---------------------
    @IBOutlet weak var locationCell: UITableViewCell!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var reminderText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    //---------------------
    //MARK: View
    //---------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Customise navigation bar
        navigationItem.title = "New"
        
        //Customise tableview
        //tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //Set the text of the location cell
        locationCell.textLabel?.text = "Location"
        locationCell.detailTextLabel?.text = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.location = nil
    }
    
    //---------------------
    //MARK: Table View
    //---------------------
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
    
    //---------------------
    //MARK: Button Actions
    //---------------------
    @IBAction func toggleValueChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            sender.setOn(false, animated: true)
            locationCell.isHidden = true
        }else {
            sender.setOn(true, animated: true)
            locationCell.isHidden = false
        }
        
    }
    
    func writeLocationBack(toLocation: CLLocation, event: String) {
        self.location = toLocation
        self.event = event
        
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
    
    @IBAction func saveButton(_ sender: UIButton) {
        guard let textField = self.reminderText.text else { return }
        self.coreDataManager.saveReminder(withText: textField, andLocation: location)
    }
    
    func saveReminder() {
        if let reminder = self.reminder, let location = self.location  {
            
            let locationToSave = Location(entity: Location.entity(), insertInto: coreDataManager.managedObjectContext)
            
            locationToSave.latitude = location.coordinate.latitude
            locationToSave.longitude = location.coordinate.longitude
            locationToSave.event = self.event
            
            reminder.location = locationToSave
            
            coreDataManager.saveContext()
        }
    }
    
    func reverseLocation() {
        
        if let locationToReverse = reminder?.location, let event = reminder?.location?.event {
            
            locationManager.reverseLocation(location: locationToReverse) { (city, street) in
                
                self.locationCell.detailTextLabel?.text = "\(event): \(city), \(street)"
            }
        }
    }
    
    //---------------------
    //MARK: Navigation
    //---------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SearchLocationView" {
            
            let searchLocationDetailVc = segue.destination as! SearchLocationTableViewController
            
            if let reminder = self.reminder {
                
                searchLocationDetailVc.reminder = reminder
                searchLocationDetailVc.delegate = self
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
