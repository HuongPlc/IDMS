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

    override func loadView() {
        super.loadView()
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        wkWebView = WKWebView(frame: view.bounds, configuration: config)
        wkWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        view = wkWebView
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

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        print("fucking js mas m")
        if keyPath == "title" {
            if let title = wkWebView.title {
                print(title)
            }
        }
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

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("ngon lanh: \(message)")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("hahahha@@@@@@_______")
        if let host = navigationAction.request.url?.host {
            if host == "www.apple.com" {
                decisionHandler(.allow)
                return
            }
        }

        decisionHandler(.cancel)
    }
}
