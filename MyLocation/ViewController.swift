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
    var myLocation:CLLocationCoordinate2D?
    
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
        map.mapType = .standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        
        if let coor = map.userLocation.location?.coordinate{
            map.setCenter(coor, animated: true)
        }
        addLongPressGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        map.showsUserLocation = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        map.showsUserLocation = false
    }
    
    func addLongPressGesture(){
        let longPressRecogniser:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target:self , action:#selector(ViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0 //user needs to press for 2 seconds
        self.map.addGestureRecognizer(longPressRecogniser)
    }
    
    func handleLongPress(_ gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state != .began{
            return
        }
        
        let touchPoint:CGPoint = gestureRecognizer.location(in: self.map)
        let touchMapCoordinate:CLLocationCoordinate2D =
            self.map.convert(touchPoint, toCoordinateFrom: self.map)
        
        let annot:MKPointAnnotation = MKPointAnnotation()
        annot.coordinate = touchMapCoordinate
        
        self.resetTracking()
        self.map.addAnnotation(annot)
        self.centerMap(touchMapCoordinate)
    }
    
    func resetTracking(){
        if (map.showsUserLocation){
            map.showsUserLocation = false
            self.map.removeAnnotations(map.annotations)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func centerMap(_ center:CLLocationCoordinate2D){
        self.saveCurrentLocation(center)
        
        let spanX = 0.007
        let spanY = 0.007
        
        let newRegion = MKCoordinateRegion(center:center , span: MKCoordinateSpanMake(spanX, spanY))
        map.setRegion(newRegion, animated: true)
    }
    
    func saveCurrentLocation(_ center:CLLocationCoordinate2D){
        let message = "\(center.latitude) , \(center.longitude)"
        print(message)
        self.lable.text = message
        myLocation = center
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        centerMap(locValue)
    }
    
    static var enable:Bool = true
    @IBAction func getMyLocation(_ sender: UIButton) {
        
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        let identifier = "pin"
        var view : MKPinAnnotationView
        if let dequeueView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView{
            dequeueView.annotation = annotation
            view = dequeueView
        }else{
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        view.pinColor =  .red
        return view
    }
    
}

