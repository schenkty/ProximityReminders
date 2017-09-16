//
//  LocationManager.swift
//  ProximityReminders
//
//  Created by Ty Schenk on 09/13/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    let geoCoder = CLGeocoder()
    var onLocationFix: ((CLPlacemark?, Error?) -> Void)?

    override init() {
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        
        //Get location permission
        getPermission()
    }
    
    //Ask user permission for location
    fileprivate func getPermission() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            //manager.requestWhenInUseAuthorization()
            manager.requestAlwaysAuthorization()
        }
    }
    
    //Reverse location
    func reverseLocation(location: Location, completion: @escaping (_ city: String, _ street: String) -> Void) {
        let locationToReverse = CLLocation(latitude: location.latitude, longitude: location.longitude)
        self.geoCoder.reverseGeocodeLocation(locationToReverse) { placemarks, error in
            if let placemark = placemarks?.first {
                guard let city = placemark.locality, let street = placemark.thoroughfare else { return }
                completion(city, street)
            }
        }
    }
    
    // Parse location address
    func parseAddress(location: MKPlacemark) -> String {
        let firstSpace = (location.subThoroughfare != nil && location.thoroughfare != nil) ? " " : ""
        //Put a comma between street and city/state
        let comma = (location.subThoroughfare != nil || location.thoroughfare != nil) && (location.subAdministrativeArea != nil || location.administrativeArea != nil) ? ", " : ""

        let secondSpace = (location.subAdministrativeArea != nil && location.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            //Street number
            location.subThoroughfare ?? "",
            firstSpace,
            //Street name
            location.thoroughfare ?? "",
            comma,
            //City
            location.locality ?? "",
            secondSpace,
            //State
            location.administrativeArea ?? "")
        
        return addressLine
    }
    
    // Drop pin on the map at the selected location and add overlay
    func dropPinZoomIn(placemark: MKPlacemark, mapView: MKMapView) {
        
        // Clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        let location = CLLocation(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
        mapView.add(MKCircle(center: location.coordinate, radius: 50))
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            if let onLocationFix = self.onLocationFix {
                onLocationFix(placemarks?.first, error)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unresolved error: \(error)")
    }
}
