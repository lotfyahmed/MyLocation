//
//  ViewController.swift
//  MyLocation
//
//  Created by Ahmed Lotfy on 6/6/16.
//  Copyright © 2016 Ahmed Lotfy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lable: UILabel!
    var myLocations: [CLLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        map.delegate = self
        map.mapType = .Standard
        map.zoomEnabled = true
        map.scrollEnabled = true
        
        if let coor = map.userLocation.location?.coordinate{
            map.setCenterCoordinate(coor, animated: true)
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        map.showsUserLocation = true;
    }
    
    override func viewWillDisappear(animated: Bool) {
        map.showsUserLocation = false
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let message = "\(locValue.latitude) , \(locValue.longitude)"
        print(message)
        
        self.lable.text = message //"\(locations[0])"
        myLocations.append(locations[0] as CLLocation)
        
        let spanX = 0.007
        let spanY = 0.007
        
        let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        
        let newRegion = MKCoordinateRegion(center:center , span: MKCoordinateSpanMake(spanX, spanY))
        map.setRegion(newRegion, animated: true)
        
        }
    
    static var enable:Bool = true
    @IBAction func getMyLocation(sender: UIButton) {
        
        if CLLocationManager.locationServicesEnabled() {
            if ViewController.enable {
                locationManager.stopUpdatingHeading()
                sender.titleLabel?.text = "Enable"
            }else{
                locationManager.startUpdatingLocation()
                sender.titleLabel?.text = "Disable"
            }
            ViewController.enable = !ViewController.enable
        }
    }
    

    
}

