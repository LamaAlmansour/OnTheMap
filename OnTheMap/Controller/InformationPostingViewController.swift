//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Lama on 19/12/2018.
//  Copyright © 2018 Lama. All rights reserved.
//


import UIKit
import CoreLocation

class InformationPostingViewController: UIViewController {

    @IBOutlet weak var location : UITextField!
    @IBOutlet weak var link : UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToNotificationsObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromNotificationsObserver()
    }
    
    @IBAction func FindLocation(_ sender: Any) {
        guard let location = location.text,
            let mediaLink = link.text,
            location != "", mediaLink != "" else {
                self.showAlert(title: "Missing information", message: "Please fill both fields and try again")
                return
        }
        
        let studentLocation = StudentLocation(mapString: location, mediaURL: mediaLink)
        geocodeCoordinates(studentLocation)
    }
    
    private func geocodeCoordinates(_ studentLocation: StudentLocation) {
        
        let ai = self.startAnActivityIndicator()
        CLGeocoder().geocodeAddressString(studentLocation.mapString!) { (placeMarks, err) in
            ai.stopAnimating()
            guard let firstLocation = placeMarks?.first?.location else { return }
            var location = studentLocation
            location.latitude = firstLocation.coordinate.latitude
            location.longitude = firstLocation.coordinate.longitude
            self.performSegue(withIdentifier: "mapSegue", sender: location)
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapSegue", let vc = segue.destination as? LocationViewController {
            vc.location = (sender as! StudentLocation)
        }
    }
    
    private func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.cancelTapped(_:)))
        
        location.delegate = self
        link.delegate = self
    }
    
    @objc private func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
