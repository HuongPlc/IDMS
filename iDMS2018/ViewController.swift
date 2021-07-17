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

    lazy var contentController: WKUserContentController = {
        var contentController = WKUserContentController()
        return contentController
    }()

    lazy var config: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()
        return config
    }()

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
        jsDemo1()
    }

    func jsDemo1() {
        let firstname = "Mickey"
        let lastname = "Mouse"

        if let buttonClick = jsContext.objectForKeyedSubscript("getFullname") {
            buttonClick.call(withArguments: nil)
        }
    }

    override func loadView() {
        super.loadView()

//        guard let scriptPath = Bundle.main.path(forResource: "script", ofType: "js"),
//              let scriptSource = try? String(contentsOfFile: scriptPath) else {
//            return
//        }
//        let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
//        contentController.addUserScript(userScript)
//

//
//        let config = WKWebViewConfiguration()
//        config.userContentController = contentController

//        let scriptSource = #"document.getElementById("link1").style.background = `red`; document.getElementById("link1").addEventListener("click", function() { document.getElementById("link1").style.background = `green`; });"#
//        let scriptSource = #"document.getElementById("link1").addEventListener("click", function() { document.getElementById("link1").style.background = `green`; });"#
        let scriptSource = #"document.getElementById("lbtLogin").addEventListener("click", function() { window.webkit.messageHandlers.haha.postMessage("Hello, world!"); });"#
        let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(script)

        if #available(iOS 14, *) {
            contentController.add(self, contentWorld: .page, name: "haha")
        }

        config.userContentController = contentController

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

//            wkWebView.loadFileURL(url, allowingReadAccessTo: url)
            print("lolo____ \(wkWebView.configuration.userContentController.userScripts[0].source)")
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
        if keyPath == "title" {
            if let title = wkWebView.title {
                let scriptSource = #"document.getElementById("spTitle").addEventListener("change", function() { window.webkit.messageHandlers.titleChange.postMessage("TitleChange"); });"#
                let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                wkWebView.configuration.userContentController.addUserScript(script)

                if #available(iOS 14, *) {
                    wkWebView.configuration.userContentController.removeScriptMessageHandler(forName: "titleChange")
                    wkWebView.configuration.userContentController.add(self, contentWorld: .page, name: "titleChange")
                    return
                }
            }
        }
        if keyPath == "estimatedProgress" {
            print(Float(wkWebView.estimatedProgress))
        }
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("ghkjh")
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("ggg")
        decisionHandler(WKNavigationActionPolicy.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        let scriptSource = #"document.getElementById("spTitle").addEventListener("change", function() { window.webkit.messageHandlers.titleChange.postMessage("TitleChange"); });"#
        let scriptSource2 = #"document.getElementById("spTitle").addEventListener("change", function() { document.getElementById("spTitle").setAttribute('name', 'w1-1'); });"#
        wkWebView.evaluateJavaScript(scriptSource2) { (data, error) in
            if error != nil {
                print("Javascript execuption failed: \(error.debugDescription)")
            } else {
                print("Add duoc user script \(data)")
            }
        }

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
        print("TitleChange \(message.)")
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
