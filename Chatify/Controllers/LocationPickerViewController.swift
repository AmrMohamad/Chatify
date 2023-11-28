//
//  LocationPickerViewController.swift
//  Chatify
//
//  Created by Amr Mohamad on 28/11/2023.
//

import UIKit
import MapKit
import CoreLocation

class LocationPickerViewController: UIViewController {

    private lazy var map: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = sendLoactionButton
        
        map.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapOnMap)
        )
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        map.addGestureRecognizer(gesture)
        view.addSubview(map)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    
    @objc func sendLoactionButtonTapped(){
        print("PICKED")
    }
    @objc func didTapOnMap(_ gesture: UITapGestureRecognizer){
        print("PICKED map")
    }
    
}