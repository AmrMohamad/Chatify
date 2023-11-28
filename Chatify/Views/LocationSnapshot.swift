//
//  LocationSnapshot.swift
//  Chatify
//
//  Created by Amr Mohamad on 28/11/2023.
//

import UIKit
import MapKit
import CoreLocation

class LocationSnapshot: UIView {

    lazy var activityIndicator: UIActivityIndicatorView = {
        let avi = UIActivityIndicatorView(style: .gray)
        avi.translatesAutoresizingMaskIntoConstraints = false
        return avi
    }()
    
    lazy var imageOfLocationSnapshot: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private weak var snapShotter : MKMapSnapshotter?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageOfLocationSnapshot)
        addSubview(activityIndicator)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            imageOfLocationSnapshot.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageOfLocationSnapshot.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageOfLocationSnapshot.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageOfLocationSnapshot.topAnchor.constraint(equalTo: topAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
            
        ])
    }
    
    func configureSnap(with location: CLLocation){
        activityIndicator.startAnimating()
        let snapshotOptions = MKMapSnapshotter.Options()
        snapshotOptions.region  = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
//        snapshotOptions.size = bounds.size
        snapshotOptions.showsBuildings = true
        let pointOfInterests : [MKPointOfInterestCategory] = [
            .airport,.amusementPark,.atm,
            .bakery,.bank,.beach,.brewery,
            .cafe,.campground,.carRental,
            .fireStation,.fitnessCenter,.foodMarket,
            .gasStation,.hospital,.hotel,.laundry,
            .library,.movieTheater,.museum,.nationalPark,
            .park,.parking,.pharmacy,.police,.postOffice,
            .restaurant,.school
        ]
        snapshotOptions.pointOfInterestFilter = MKPointOfInterestFilter(including: pointOfInterests)
        
        let snShotter = MKMapSnapshotter(options: snapshotOptions)
        snShotter.start { [weak self] snapshot, error in
            guard let strongSelf = self else {return}
            if error != nil {
                print(error!)
                return
            }
            let annotationView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            annotationView.pinTintColor = .red
            
            UIGraphicsBeginImageContextWithOptions(snapshotOptions.size, true, 0)
            if let snapshot = snapshot {
                snapshot.image.draw(at: .zero)
                var point = snapshot.point(for: location.coordinate)
                // Move point to reflect annotation anchor
                point.x -= annotationView.bounds.size.width / 2
                point.y -= annotationView.bounds.size.height / 2
                point.x += annotationView.centerOffset.x
                point.y += annotationView.centerOffset.y
                
                annotationView.image?.draw(at: point)
                let composedImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                strongSelf.imageOfLocationSnapshot.image = composedImage
                strongSelf.activityIndicator.stopAnimating()
            }
        }
    }
}
