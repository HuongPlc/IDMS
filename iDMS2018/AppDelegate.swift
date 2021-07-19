//
//  AppDelegate.swift
//  iDMS2018
//
//  Created by Huong on 7/15/21.
//  Copyright © 2021 IDMS2018. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var configInfo: ConfigInfo?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let config: ConfigInfo? = ConfigInfoService.shared.getInfo(for: Constants.ConfigInfo.name)
        if config == nil {
            let vc = ConfigViewController()
            vc.edms = config?.edms
            vc.companyCode = config?.companyCode
            let nc = UINavigationController(rootViewController: vc)
            nc.isNavigationBarHidden = true
            window = UIWindow(frame: UIScreen.main.bounds)

            window?.rootViewController = nc

            window?.makeKeyAndVisible()

            return true
        }

        let vc = ViewController()
        let nc = UINavigationController(rootViewController: vc)
        nc.isNavigationBarHidden = true

        window = UIWindow(frame: UIScreen.main.bounds)

        window?.rootViewController = nc

        window?.makeKeyAndVisible()

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.host?.isEmpty == true && url.path.isEmpty == true {
            return true
        }
        var companyCode = url.path
        companyCode.removeFirst()
        configInfo = ConfigInfo(edms: url.host, companyCode: companyCode)
        return true
    }
}
