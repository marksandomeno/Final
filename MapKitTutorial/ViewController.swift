//
//  ViewController.swift
//  ExplorerApp
//
//  Created by Tyler on 4/17/19.
//  Copyright © 2019. Tyler All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {

    @IBAction func shuffleButton(_ sender: Any) {
        
        var addressArray: [String] = ["120 Northfield Ave","Osteria Francescana, Modena, Italy","El Celler de Can Roca, Girona, Spain","Mirazur, France","Eleven Madison Park, New York, USA","Gaggan, Bangkok, Thailand","Central, Lima, Peru","Steirereck, Austria","White Rabbit, Russia","Piazza Duomo, Italy","Narisawa, Tokyo, Japan","Odette, Singapore","Le Bernadin, New York, USA","Septime, Paris, France","Saison, San Francisco, USA"]
        let randIndex = Int.random(in: 0..<15)
        
        
        
        localSearchRequest = MKLocalSearch.Request()
        localSearchRequest.naturalLanguageQuery = addressArray[randIndex]
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { [weak self] (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil {
                let alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
                alert.show()
                return
            }
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = addressArray[randIndex]
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self!.mapView.centerCoordinate = pointAnnotation.coordinate
            self!.mapView.addAnnotation(pinAnnotationView.annotation!)
        }
        
        
    }
    
	
	@IBOutlet weak var mapView: MKMapView!
	

	
	fileprivate var searchController: UISearchController!
	fileprivate var localSearchRequest: MKLocalSearch.Request!
	fileprivate var localSearch: MKLocalSearch!
	fileprivate var localSearchResponse: MKLocalSearch.Response!
	
	
	
	fileprivate var annotation: MKAnnotation!
	fileprivate var locationManager: CLLocationManager!
	fileprivate var isCurrentLocation: Bool = false
	

	
	fileprivate var activityIndicator: UIActivityIndicatorView!
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
        let currentLocationButton = UIBarButtonItem(title: "My Location", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ViewController.currentLocationButtonAction(_:)))
		self.navigationItem.leftBarButtonItem = currentLocationButton
        self.navigationItem.title = "🧭 Restaurant Explorer"
		
		let searchButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(ViewController.searchButtonAction(_:)))
		self.navigationItem.rightBarButtonItem = searchButton
		
		mapView.delegate = self
        
            mapView.mapType = .hybrid
      
		
		activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
		activityIndicator.hidesWhenStopped = true
		self.view.addSubview(activityIndicator)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		activityIndicator.center = self.view.center
	}
	

	
	@objc func currentLocationButtonAction(_ sender: UIBarButtonItem) {
		if (CLLocationManager.locationServicesEnabled()) {
			if locationManager == nil {
				locationManager = CLLocationManager()
			}
			locationManager?.requestWhenInUseAuthorization()
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.requestAlwaysAuthorization()
			locationManager.startUpdatingLocation()
			isCurrentLocation = true
		}
	}
	

	
	@objc func searchButtonAction(_ button: UIBarButtonItem) {
		if searchController == nil {
			searchController = UISearchController(searchResultsController: nil)
		}
		searchController.hidesNavigationBarDuringPresentation = false
		self.searchController.searchBar.delegate = self
		present(searchController, animated: true, completion: nil)
	}
	

	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		dismiss(animated: true, completion: nil)
		
		if self.mapView.annotations.count != 0 {
			annotation = self.mapView.annotations[0]
			self.mapView.removeAnnotation(annotation)
		}
		
		localSearchRequest = MKLocalSearch.Request()
		localSearchRequest.naturalLanguageQuery = searchBar.text
		localSearch = MKLocalSearch(request: localSearchRequest)
		localSearch.start { [weak self] (localSearchResponse, error) -> Void in
			
			if localSearchResponse == nil {
				let alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
				alert.show()
				return
			}
			
			let pointAnnotation = MKPointAnnotation()
			pointAnnotation.title = searchBar.text
			pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
			
			let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
			self!.mapView.centerCoordinate = pointAnnotation.coordinate
			self!.mapView.addAnnotation(pinAnnotationView.annotation!)
		}
	}
	

	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if !isCurrentLocation {
			return
		}
		
		isCurrentLocation = false
		
		let location = locations.last
		let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
		let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
		
		self.mapView.setRegion(region, animated: true)
		
		if self.mapView.annotations.count != 0 {
			annotation = self.mapView.annotations[0]
			self.mapView.removeAnnotation(annotation)
		}
		
		let pointAnnotation = MKPointAnnotation()
		pointAnnotation.coordinate = location!.coordinate
		pointAnnotation.title = ""
		mapView.addAnnotation(pointAnnotation)
	}

}

