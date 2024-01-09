//
//  LocationPickerViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 28/11/2023.
//

import CoreLocation
import MapKit
import UIKit

class LocationPickerViewController: UIViewController, CLLocationManagerDelegate {
    private lazy var map: MKMapView = {
        let map = MKMapView()
        return map
    }()

    let locationManager = CLLocationManager()
    private var coordinates: CLLocationCoordinate2D?
    public var completion: ((CLLocationCoordinate2D) -> Void)?
    var isPickable: Bool = true

    private lazy var sendLoactionButton: UIBarButtonItem = {
        let cButton = UIButton(type: .system)
        cButton.setTitle("Send", for: .normal)
        cButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        cButton.layer.shadowRadius = 2.9
        cButton.layer.shadowOpacity = 0.50
        cButton.layer.shadowColor = UIColor.black.cgColor
        cButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        cButton.addTarget(self, action: #selector(sendLoactionButtonTapped), for: .touchUpInside)
        let button = UIBarButtonItem(customView: cButton)
        return button
    }()

    init(coordinates: CLLocationCoordinate2D?) {
        super.init(nibName: nil, bundle: nil)
        self.coordinates = coordinates
        isPickable = coordinates == nil
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        if isPickable {
            navigationItem.rightBarButtonItem = sendLoactionButton

            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()

            let gesture = UITapGestureRecognizer(
                target: self,
                action: #selector(didTapOnMap)
            )
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)
        } else {
            guard let coordinates = coordinates else {
                return
            }
            let pin = MKPointAnnotation()
            pin.coordinate = coordinates
            map.addAnnotation(pin)
            renderMap(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude))
        }

        map.isUserInteractionEnabled = true

        view.addSubview(map)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }

    @objc func sendLoactionButtonTapped() {
        if let coordinates = coordinates {
            completion?(coordinates)
            navigationController?.popViewController(animated: true)
        }
    }

    @objc func didTapOnMap(_ gesture: UITapGestureRecognizer) {
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates

        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }

        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        map.addAnnotation(pin)
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            renderMap(location)
        }
    }

    func renderMap(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )

        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        map.setRegion(region, animated: true)
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
