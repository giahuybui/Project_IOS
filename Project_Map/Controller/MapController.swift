import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    // Button action for search button
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
    
    // MARK: - CLLocationManagerDelegate
    
    // Handle updating of user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Get the last updated location
        guard let location = locations.last else {
            return
        }
        
        currentLocation = location
        
        // Set the region of the map to display the user's location
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
        
        // Add an annotation for the current location
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = "Vị trí hiện tại"
        mapView.addAnnotation(annotation)
        
        locationManager.stopUpdatingLocation()
    }
    
    // Handle location manager errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Lỗi lấy vị trí: \(error.localizedDescription)")
    }
    
    // MARK: - Gesture Recognizer
    
    // Handle tap gesture on the map
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        // Remove previous annotation if exists
        if let previos = previousAnnotation {
            mapView.removeAnnotation(previos)
        }
        
        // Add a new annotation for the tapped location
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Điểm mới"
        mapView.addAnnotation(annotation)
        
        // Draw route from current location to the tapped location
        if let location = currentLocation {
            let current = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate))
            
            // Remove current route overlay if exists
            if let currentRouteOverlay = currentRouteOverlay {
                mapView.removeOverlay(currentRouteOverlay)
            }
            
            drawRoute(from: current, to: destination)
            
            // Calculate distance between current location and tapped location
            let distance = location.distance(from: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
            let distanceString = String(format: "%.2f", distance)
            
            let alertController = UIAlertController(title: "Khoảng cách", message: "Khoảng cách giữa vị trí hiện tại và điểm mới là \(distanceString) mét", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                // Handle OK button action if needed
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        previousAnnotation = annotation
    }
    
    // MARK: - Map Routing
    
    // Draw route on the map between two locations
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
    
    // Customize the renderer for map overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    // MARK: - UISearchBarDelegate
    
    // Handle search button clicked in the search bar
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
                self.copyCoordinateToClipboard(annotation.coordinate)
                
                // Calculate distance between current location and previous annotation
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
    
    // MARK: - Helper Functions
    
    // Copy coordinate to clipboard
    func copyCoordinateToClipboard(_ coordinate: CLLocationCoordinate2D) {
        let pasteboard = UIPasteboard.general
        let coordinateString = "\(coordinate.latitude), \(coordinate.longitude)"
        pasteboard.string = coordinateString
    }
}
