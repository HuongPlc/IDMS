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
    private var wkWebView: WKWebView!
    var first: Bool = false

    var contentController: WKUserContentController?
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        return locationManager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadWebView()
    }

    private func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center: CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        // 21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        // 72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon

        let loc: CLLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)

        ceo.reverseGeocodeLocation(loc, completionHandler: { placemarks, error in
            if error != nil {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            let pm = placemarks! as [CLPlacemark]

            if pm.count > 0 {
                let pm = placemarks![0]
                var addressString: String = ""
                if pm.subLocality != nil {
                    addressString = addressString + pm.subLocality! + " - "
                }
                if pm.thoroughfare != nil {
                    addressString = addressString + pm.thoroughfare! + " - "
                }
                if pm.locality != nil {
                    addressString = addressString + pm.locality! + " - "
                }
                if pm.country != nil {
                    addressString = addressString + pm.country! + " - "
                }
                if pm.postalCode != nil {
                    addressString = addressString + pm.postalCode! + " - "
                }

                let uploadGPS = #"setGPS(""# + pdblLatitude + "/" + pdblLongitude + "/" + addressString + "\"" + ")"
                let setGeo = #"setGeo(""# + pdblLatitude + "/" + pdblLongitude + "/" + addressString + "\"" + ")"
                print("GPS: \(uploadGPS). \(addressString)")
                self.wkWebView.evaluateJavaScript(uploadGPS) { _, _ in
                    print("Finished update GPS")
                }
                self.wkWebView.evaluateJavaScript(setGeo) { _, _ in
                    print("Finished update GPS")
                }
            }
        })
    }

    override func loadView() {
        super.loadView()

        let source = """
        window.addEventListener('click', function(e) {
            window.webkit.messageHandlers.buttonClick.postMessage(JSON.stringify(e.target.id));
        });
        """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController?.removeAllUserScripts()

        let config = WKWebViewConfiguration()
        contentController = WKUserContentController()
        config.userContentController = contentController!

        contentController?.addUserScript(script)

        config.userContentController = contentController!

        wkWebView = WKWebView(frame: view.bounds, configuration: config)
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self
        wkWebView.configuration.preferences.javaScriptEnabled = true
        wkWebView.configuration.userContentController.add(self, name: "buttonClick")

        wkWebView.navigationDelegate = self
        view = wkWebView
    }

    deinit {
        locationManager.stopUpdatingLocation()
    }

    private func loadWebView() {
        if let url = URL(string: Constants.WebView.urlApp) {
            let urlRequest = URLRequest(url: url)
            wkWebView.load(urlRequest)
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

extension ViewController: WKNavigationDelegate {
}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, contextMenuForElement elementInfo: WKContextMenuElementInfo, willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        print("button tapped")
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        let imageData = image.pngData()!
        let encode = imageData.base64EncodedString()
        let jsToCode = #"uploadImg(""# + encode + "\"" + ")"
        picker.dismiss(animated: true, completion: nil)
        self.wkWebView.evaluateJavaScript(jsToCode) { _, _ in
            print("Finished evaluating javascript code")
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude.description
            let longitude = location.coordinate.longitude.description

            getAddressFromLatLon(pdblLatitude: latitude, withLongitude: longitude)
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

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        let idJson = message.body as! String
        let startIndex = idJson.index(idJson.startIndex, offsetBy: 0)
        let endIndex = idJson.index(idJson.endIndex, offsetBy: 0)
        let id = idJson[startIndex..<endIndex]
        if id == "\"showroom-camera-shot\"" {
            pickImage(usingCamera: true)
        }
        if id == "\"goto-GPS\"" || id == "\"showroom-refresh-GPS\"" {
            locationManager.requestLocation()
        }
    }
}
