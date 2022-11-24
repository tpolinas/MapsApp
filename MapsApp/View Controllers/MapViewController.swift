//
//  MapViewController.swift
//  MapsApp
//
//  Created by Polina Tikhomirova on 22.11.2022.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

class MapViewController: UIViewController {
    var isTracking = false
    var coordinates: [AnnotationRealm] = []
    var coordinatesFromRealm: Results<AnnotationRealm>?
    
    private(set) lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.distanceFilter = 10
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        return manager
    }()
    
    private(set) lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isZoomEnabled = true
        
        return mapView
    }()
    
    private(set) lazy var trackLocationButton: UIBarButtonItem = {
        var buttonItem = UIBarButtonItem(
            image: UIImage(systemName: "location"),
            style: .plain,
            target: self,
            action: #selector(self.trackLocation))
        
        return buttonItem
    }()
    
    private(set) lazy var currentLocationButton: UIBarButtonItem = {
        var buttonItem = UIBarButtonItem(
            image: UIImage(systemName: "location"),
            style: .plain,
            target: self,
            action: #selector(self.getCurrentLoation))
        
        return buttonItem
    }()
    
    private(set) lazy var showPreviousRouteButton: UIButton = {
        var button = UIButton(configuration: UIButton.Configuration.borderedTinted())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show Previous Route", for: .normal)
        button.addTarget(
            self,
            action: #selector(self.getPreviousRoute),
            for: .touchUpInside)
        
        return button
    }()
    
    private(set) lazy var exitButton: UIButton = {
        var button = UIButton(configuration: UIButton.Configuration.borderedTinted())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .red
        button.setTitle("Exit", for: .normal)
        button.addTarget(
            self,
            action: #selector(self.getBack),
            for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        configureUI()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    private func configureUI() {
        navigationItem.leftBarButtonItem = trackLocationButton
        navigationItem.rightBarButtonItem = currentLocationButton
        
        self.addSubviews()
        self.configureConstraints()
        self.updateButton()
    }
    
    private func addSubviews() {
        self.view.addSubview(mapView)
        self.view.addSubview(showPreviousRouteButton)
        self.view.addSubview(exitButton)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            showPreviousRouteButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            showPreviousRouteButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            showPreviousRouteButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            
            exitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            exitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 70),
            exitButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func goToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func setTheMark(to location: CLLocation, with title: String?) {
        let mark = MKPointAnnotation()
        mark.title = title
        mark.coordinate = location.coordinate
        self.mapView.addAnnotation(mark)
        print(self.mapView.annotations.count)
    }
    
    private func saveToRealm(_ items: [AnnotationRealm]) {
        self.deleteAllDataFromRealm()
        do {
            try RealmService.save(items: items)
        } catch {
            print("Saving to Realm has been failed")
        }
        self.coordinates = []
    }
    
    private func deleteAllDataFromRealm() {
        do {
            try RealmService.deleteAll()
        } catch {
            print("Deleting from Realm has failed")
        }
    }
    
    private func loadDataFromRealm() {
        do {
            self.coordinatesFromRealm = try RealmService.get(type: AnnotationRealm.self)
        } catch {
            print("Download from Realm has failed")
        }
    }
    
    private func updateToTheCurrentLocation(_ location: CLLocation) {
        let viewRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 200,
            longitudinalMeters: 200)
        self.mapView.setRegion(viewRegion, animated: true)
    }
    
    private func updateButton() {
        if isTracking {
            trackLocationButton.setBackgroundImage(
                UIImage(systemName: "location.fill.viewfinder"),
                for: .normal,
                barMetrics: .default)
        } else {
            trackLocationButton.setBackgroundImage(
                UIImage(systemName: "location.viewfinder"),
                for: .normal,
                barMetrics: .default)
        }
    }
    
    private func presentAlert() {
        let alertController = UIAlertController(
            title: "Error",
            message: "You should disable tracking to continue.",
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: "OK",
            style: .default) { action in
                if self.isTracking {
                    self.trackLocation()
                    self.showExistingRoute()
                }
            }
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    private func showExistingRoute() {
        loadDataFromRealm()
        let directionRequest = MKDirections.Request()
        guard
            let firstPoint = coordinatesFromRealm?.first,
            let lastPoint = coordinatesFromRealm?.last
        else { return }
        
        let firstLocation = CLLocationCoordinate2D(
            latitude: firstPoint.latitude,
            longitude: firstPoint.longitude)
        let lastLocation = CLLocationCoordinate2D(
            latitude: lastPoint.latitude,
            longitude: lastPoint.longitude)
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: firstLocation))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: lastLocation))
        directionRequest.transportType = .any
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            guard let unwrappedResponse = response else { return }
            let route = unwrappedResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(
                MKCoordinateRegion(rect),
                animated: true)
        }
    }
    
    // MARK: - Obj-C methods
    
    @objc func trackLocation() {
        if isTracking && !self.coordinates.isEmpty {
            saveToRealm(coordinates)
        }
        isTracking.toggle()
        updateButton()
    }
    
    @objc func getCurrentLoation() {
        if let currentLocation = locationManager.location {
            updateToTheCurrentLocation(currentLocation)
        }
    }
    
    @objc func getPreviousRoute() {
        if isTracking {
            presentAlert()
        } else {
            showExistingRoute()
        }
    }
    
    @objc func getBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

    // MARK: - Extensions

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        render.strokeColor = UIColor.systemBlue
        render.lineWidth = 5
        return render
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.isTracking {
            if let lastLocation = locations.last {
                self.updateToTheCurrentLocation(lastLocation)
                self.coordinates.append(AnnotationRealm(
                    original: Annotation(
                        lat: lastLocation.coordinate.latitude,
                        long: lastLocation.coordinate.longitude)))
                self.setTheMark(to: lastLocation, with: nil)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}
