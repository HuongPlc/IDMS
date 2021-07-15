//
//  ViewController.swift
//  iDMS2018
//
//  Created by Huong on 7/15/21.
//  Copyright © 2021 IDMS2018. All rights reserved.
//

import CoreLocation
import UIKit
import WebKit

class ViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet var wkWebView: WKWebView!

    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.startUpdatingLocation()
        loadWebView()
    }

    deinit {
        locationManager.stopUpdatingLocation()
    }

    private func loadWebView() {
        if let url = URL(string: Constants.WebView.urlApp) {
            wkWebView.load(URLRequest(url: url))
            wkWebView.allowsBackForwardNavigationGestures = true
        }
    }



    private func pickImage(usingCamera: Bool) {
        let vc = UIImagePickerController()
        vc.sourceType = usingCamera ? .camera : .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        print("imaeg size \(image.size)")
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            // Handle location update
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Handle failure to get a user’s location
    }
}
