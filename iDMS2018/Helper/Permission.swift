//
//  Permission.swift
//  iDMS2018
//
//  Created by Huong on 7/15/21.
//  Copyright © 2021 IDMS2018. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import CoreLocation

enum PermissionType {
    case camera
    case photo
    case location
    case all
}

struct RequestPermission {
    static func request(_ types: [PermissionType]) {
        for type in types {
            if type == .all {
                requestPhotoPermission()
                requestCameraPermission()
                requestLocationPermission()
                return
            }
            if type == .camera {
                requestCameraPermission()
            }
            if type == .photo {
                requestCameraPermission()
            }
            if type == .location {
                requestCameraPermission()
            }
        }
    }

    static func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                //access granted
            } else {

            }
        }
    }

    static func requestPhotoPermission() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{

                } else {

                }
            })
        }
    }

    static func requestLocationPermission() {
        let status = CLLocationManager.authorizationStatus()

        // Handle each case of location permissions
        switch status {
            case .authorizedAlways:
                // Handle case
                print("authorizedAlways")
            case .authorizedWhenInUse:
                // Handle case
                print("authorizedWhenInUse")
            case .denied:
                // Handle case
                print("denied")
            case .notDetermined:
                // Handle case
                print("notDetermined")
            case .restricted:
                // Handle case
                print("restricted")
            default:
                print("unknow")
        }
    }

}
