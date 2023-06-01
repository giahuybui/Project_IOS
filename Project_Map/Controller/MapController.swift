//
//  MapViewController.swift
//  Project_Map
//
//  Created by CNTT on 5/30/23.
//  Copyright © 2023 fit.tdc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class MapController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate,UISearchBarDelegate {
    
    @IBAction func searchButton(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var previousAnnotation: MKPointAnnotation?
    var currentRouteOverlay: MKOverlay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture);
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        currentLocation = location
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "Vị trí hiện tại"
        mapView.addAnnotation(annotation)
        
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Lỗi lấy vị trí: \(error.localizedDescription)")
    }
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        
        if let previos = previousAnnotation{
            mapView.removeAnnotation(previos)
            
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Điểm mới"
        mapView.addAnnotation(annotation)
        
        if let location = currentLocation {
            let current = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate))
            
            if let currentRouteOverlay = currentRouteOverlay {
                mapView.removeOverlay(currentRouteOverlay)
            }
            
            drawRoute(from: current, to: destination)
            
            let distance = location.distance(from: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
            print("Khoảng cách giữa vị trí hiện tại và điểm mới là \(distance) mét")
        }
        
        previousAnnotation = annotation
    }
    
    
    
    //phuong thuc d  duong di tu a den B
    func drawRoute(from source: MKMapItem, to destination: MKMapItem) {
        if let currentRouteOverlay = currentRouteOverlay {
            mapView.removeOverlay(currentRouteOverlay)
        }
        
        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                if let error = error {
                    print("Lỗi tính toán đường đi: \(error.localizedDescription)")
                }
                return
            }
            
            self.currentRouteOverlay = route.polyline
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
        }
    }
    
    //xu ly ve mau cho duong di
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    //search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Ignore user interaction
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Show activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        // Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        // Create the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if let error = error {
                print("Lỗi tìm kiếm: \(error.localizedDescription)")
                return
            }
            
            guard let response = response else {
                print("Không có kết quả tìm kiếm.")
                return
            }
            
            // Remove previous annotations
            let annotations = self.mapView.annotations
            self.mapView.removeAnnotations(annotations)
            
            // Getting the first result
            if let firstResult = response.mapItems.first {
                let annotation = MKPointAnnotation()
                annotation.title = firstResult.name
                annotation.coordinate = firstResult.placemark.coordinate
                
                // Calculate distance
                if let previousAnnotation = self.previousAnnotation {
                    let currentLocationTemp = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                    let distance = currentLocationTemp.distance(from: CLLocation(latitude: previousAnnotation.coordinate.latitude, longitude: previousAnnotation.coordinate.longitude))
                    print("Khoảng cách giữa vị trí hiện tại và điểm mới là \(distance) mét")
                }
                
                self.currentLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                self.mapView.addAnnotation(annotation)
                
                // Zooming in on the annotation
                let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                
                self.previousAnnotation = annotation
            }
        }
    }
    
    
}
