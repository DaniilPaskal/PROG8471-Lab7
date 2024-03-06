//
//  ViewController.swift
//  Lab7
//
//  Created by user237236 on 3/5/24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    // Location manager
    let manager = CLLocationManager()
    
    // Variables for trip data to be displayed in app
    var currentSpeed: CLLocationSpeed = 0
    var maxSpeed: CLLocationSpeed = 0
    var averageSpeed: CLLocationSpeed = 0
    var distance: CLLocationDistance = 0
    var maxAcceleration: Double = 0
    
    // Speed sum and counter for getting average speed
    var speedSum: CLLocationSpeed = 0
    var speedCounter: Double = 0
    
    // Previous location for getting distance
    var prevLocation: CLLocation = CLLocation()
    
    // Start time for getting max acceleration
    var startTime: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    
    // Label displaying current speed
    @IBOutlet weak var labelCurrentSpeed: UILabel!
    
    // Label displaying max speed
    @IBOutlet weak var labelMaxSpeed: UILabel!
    
    // Label displaying average speed
    @IBOutlet weak var labelAverageSpeed: UILabel!
    
    // Label displaying distance
    @IBOutlet weak var labelDistance: UILabel!
    
    // Label displaying acceleration
    @IBOutlet weak var labelMaxAcceleration: UILabel!
    
    // View that turns red when speec > 115 km/h
    @IBOutlet weak var viewSpeed: UIView!
    
    // View that turns green when trip in progress
    @IBOutlet weak var viewTrip: UIView!
    
    // Map view
    @IBOutlet weak var mapView: MKMapView!
    
    // Button to start trip
    @IBAction func buttonStart(_ sender: Any) {
        // Start updating location; set trip view to green
        manager.startUpdatingLocation()
        viewTrip.backgroundColor = .green
    }
    
    // Button to stop trip
    @IBAction func buttonStop(_ sender: Any) {
        // Stop updating location; set trip view to grey
        viewTrip.backgroundColor = .systemGray3
        manager.stopUpdatingLocation()
    }
    
    // Update global variables with trip data for display from current location
    func getTripData(location: CLLocation) {
        // Get current time
        let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        
        // Get current speed
        currentSpeed = location.speed
        
        // Add distance between current and previous locations to total distance
        distance += location.distance(from: prevLocation)
        
        // Add current speed to sum and increment counter, then get average speed
        speedSum += currentSpeed
        speedCounter += 1
        averageSpeed = speedSum / speedCounter
        
        // If current speed exceeds previous maximum, set max speed to current
        if (currentSpeed > maxSpeed) {
            maxSpeed = currentSpeed
        }
        
        // Calculate acceleration using distance travelled over time
        let acceleration = (2 * distance) / Double(currentTime - startTime)
        
        // If current acceleration exceeds previous maximum, set max acceleration to current
        if (acceleration > maxAcceleration) {
            maxAcceleration = acceleration
        }
        
        // Set previous location to current
        prevLocation = location
    }
    
    // Set labels and views using trip data
    func displayTripData() {
        // Set labels
        labelCurrentSpeed.text = String(format: "%.2f km/h", currentSpeed)
        labelMaxSpeed.text = String(format: "%.2f km/h", maxSpeed)
        labelAverageSpeed.text = String(format: "%.2f km/h", averageSpeed)
        labelDistance.text = String(format: "%.2f km", distance / 1000)
        labelMaxAcceleration.text = String(format: "%.2f m/s^2", maxAcceleration)
        
        // If current speed >= 115 km/h, set speed view to red (it will remain red even if speed goes down again)
        if (currentSpeed >= 115) {
            viewSpeed.backgroundColor = .red
        }
    }
    
    // Set location and update render function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {
        if let location = location.first {
            manager.startUpdatingLocation()
            render(location)
        }
        
        // Attempt to get current location
        guard let currentLocation = manager.location
        else {
            return
        }
        
        // Get trip data to display
        getTripData(location: currentLocation)
        
        // Display trip data
        displayTripData()
    }
    
    // Set region and pin for original location
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let pin = MKPointAnnotation()
        
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        mapView.setRegion(region, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make map visible and set original location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        mapView.delegate = self
        
        // Initialize previous location as start location
        prevLocation = manager.location ?? CLLocation()
    }

}

