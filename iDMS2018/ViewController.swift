//
//  ViewController.swift
//  iDMS2018
//
//  Created by Huong on 7/15/21.
//  Copyright © 2021 IDMS2018. All rights reserved.
//

import CoreLocation
import JavaScriptCore
import UIKit
import WebKit

class ViewController: UIViewController, UINavigationControllerDelegate {
    private var wkWebView: WKWebView!
    var jsContext: JSContext!
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
        // Do any additional setup after loading the view.
//        locationManager.startUpdatingLocation()
        locationManager.requestLocation()
        jsContext = JSContext()

        loadWebView()

        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            var jsToCode = #"uploadImg("")"#

            var uploadGPS = #"setGPS("21.4/105.43")"#
            self.wkWebView.evaluateJavaScript(uploadGPS) { _, _ in
                print("Finished evaluating javascript code")
            }
        }
        locationManager.requestLocation()
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
                print(pm.country)
                print(pm.locality)
                print(pm.subLocality)
                print(pm.thoroughfare)
                print(pm.postalCode)
                print(pm.subThoroughfare)
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

                var uploadGPS = #"setGPS("# + pdblLatitude + "/" + pdblLongitude + "\"" + ")"
                var setGeo = #"setGeo("# + addressString + "\"" + ")"
                print("GPS: \(uploadGPS). \(addressString)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    self.wkWebView.evaluateJavaScript(uploadGPS) { _, _ in
                        print("Finished update GPS")
                    }
                    self.wkWebView.evaluateJavaScript(setGeo) { _, _ in
                        print("Finished update GPS")
                    }
                }
            }
        })
    }

    override func loadView() {
        super.loadView()

//        guard let scriptPath = Bundle.main.path(forResource: "script", ofType: "js"),
//            let scriptSource = try? String(contentsOfFile: scriptPath) else {
//            return
//        }
//        let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
//        contentController!.addUserScript(userScript)
//

        let scriptSource = #"document.getElementById("customer-search").addEventListener("click", function() { window.webkit.messageHandlers.haha.postMessage("Hello, world!"); });"#
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController?.removeAllUserScripts()

        let config = WKWebViewConfiguration()
        contentController = WKUserContentController()
        config.userContentController = contentController!

//        let scriptSource = #"document.getElementById("link1").style.background = `red`; document.getElementById("link1").addEventListener("click", function() { document.getElementById("link1").style.background = `green`; });"#
//        let scriptSource = #"document.getElementById("link1").addEventListener("click", function() { document.getElementById("link1").style.background = `green`; });"#

//        let scriptSource = #"document.getElementById("customer-search").addEventListener("click", function() { window.webkit.messageHandlers.haha.postMessage("Hello, world!"); });"#
//        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController?.addUserScript(script)

        contentController?.add(self, name: "buttonClick")

        if #available(iOS 14, *) {
            contentController?.add(self, name: "nativeProcess")
        }

        config.userContentController = contentController!

        wkWebView = WKWebView(frame: view.bounds, configuration: config)
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self

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
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("ghkjh")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("ggg  \(navigationAction.request.url)")
        decisionHandler(WKNavigationActionPolicy.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        let scriptSource = #"document.getElementById("spTitle").addEventListener("change", function() { window.webkit.messageHandlers.titleChange.postMessage("TitleChange"); });"#
//        let scriptSource2 = #"document.getElementById("spTitle").addEventListener("change", function() { document.getElementById("spTitle").setAttribute('name', 'w1-1'); });"#
//        wkWebView.evaluateJavaScript(scriptSource2) { (data, error) in
//            if error != nil {
//                print("Javascript execuption failed: \(error.debugDescription)")
//            } else {
//                print("Add duoc user script \(data)")
//            }
//        }
//        let scriptSource = #"document.getElementsByClassName("goto-showroom")[0].addEventListener("click", function() { window.webkit.messageHandlers.haha.postMessage(goto-showroom"); });"#
//        webView.evaluateJavaScript(scriptSource) { _, error in
//            if error != nil {
//                print("No thing \(error)")
//            }
//        }

        if let url = webView.url {
            if url.absoluteString == "http://idms2018.nazzy.vn/Mobile2/demo" && first {
//                let scriptSource = #"document.getElementById("customer-search").addEventListener("click", function() { window.webkit.messageHandlers.haha.postMessage("Hello, world!"); });"#
                let scriptSource = #"document.body.style.background = `red`;"#
                webView.evaluateJavaScript(scriptSource, completionHandler: nil)
//                let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//                contentController?.removeAllUserScripts()
//                contentController?.addUserScript(script)
//                contentController?.add(self, name: "haha")

                let urlRequest = URLRequest(url: url)
                wkWebView.load(urlRequest)
                wkWebView.allowsBackForwardNavigationGestures = true
                first.toggle()
            }
        }

//        let scriptSource = #"console.log(document.getElementsByClassName("goto-showroom"));"#
//        webView.evaluateJavaScript(scriptSource) { (status, error) in
//            if error != nil {
//                print("No thing \(error)")
//            }
//        }
    }
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
        print("imaeg size \(image.size)")

        picker.dismiss(animated: true, completion: nil)
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
        print("TitleChange \(message.body)")
        var jsToCode = #"changeEcho("ngon lanh")"#
        wkWebView.evaluateJavaScript(jsToCode) { _, _ in
            print("Finished hahahahahhe")
        }
    }

//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        if let host = navigationAction.request.url?.host {
//            if host == "www.apple.com" {
//                decisionHandler(.allow)
//                return
//            }
//        }
//
//        decisionHandler(.cancel)
//    }
}
