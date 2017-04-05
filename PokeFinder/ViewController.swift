//
//  ViewController.swift
//  PokeFinder
//
//  Created by Patrick Polomsky on 4/3/17.
//  Copyright © 2017 Patrick Polomsky. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class ViewController: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var mapHasCenteredOnce = false
    var geoFire: GeoFire!
    var geoFireReference: FIRDatabaseReference!
    var pokemon = [Pokemon]()
    var pokeAnno: PokeAnnotation!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
     
       
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        geoFireReference = FIRDatabase.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireReference)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
        
    }


    
      // REQUEST USER AUTHORIZATION FOR THE MAP
    
    func locationAuthStatus() {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
         mapView.showsUserLocation = true
            
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
         
            mapView.showsUserLocation = true
        }
    }
    
    //CREATES THE MAP BOUNDS THAT WILL BE CENTERED ON
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    //ALLOWS THE MAP TO CENTER TO USER LOCATION ONLY ONCE AT THE START OF THE APP
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if let loc = userLocation.location {
        
        if !mapHasCenteredOnce {
            
            centerMapOnLocation(location: loc)
            mapHasCenteredOnce = true
            
            }
        }
    }
    
    func createSighting(forLocation location: CLLocation, withPokemon pokeId: Int) {
        
            geoFire.setLocation(location, forKey: "\(pokeId)")
        
    }
    
    //CREATES THE ANNOTATION OF THE USERS LOCATION, WHERE YOU CREATE ALL CUSTOM ANNOTATIONS
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
     
        let annoIdentifier = "Pokemon"
        
        var annotationView: MKAnnotationView!
        
        if annotation.isKind(of: MKUserLocation.self) {
         
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            
            annotationView.image = UIImage(named: "ash")
        
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            annotationView = deqAnno
            annotationView.annotation = annotation
        } else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView, let anno = annotation as? PokeAnnotation {
            
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "\(anno.pokeId)")
            let button = UIButton()
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.setImage(UIImage(named: "map"), for: .normal)
            annotationView.rightCalloutAccessoryView = button
        }
        
        return annotationView
    }
    
    func showSightingsOnMap(location: CLLocation) {
        
        let circleQuery = geoFire.query(at: location, withRadius: 2.5)
        
        _ = circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            
            if let key = key, let location = location {
                
                let anno = PokeAnnotation(coordinate: location.coordinate, pokeId: Int(key)!)
                
                self.mapView.addAnnotation(anno)
            }
            
        })
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        showSightingsOnMap(location: loc)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let anno = view.annotation as? PokeAnnotation {
            
            let place = MKPlacemark(coordinate: anno.coordinate)
            let destination = MKMapItem(placemark: place)
            destination.name = "Pokemon Sighting"
            let regionDistance: CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
    }

    @IBAction func spotRandomPokemon(_ sender: Any) {
        
        let location = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        let rand = arc4random_uniform(151) + 1
        
        createSighting(forLocation: location, withPokemon: Int(rand))
    }


}

