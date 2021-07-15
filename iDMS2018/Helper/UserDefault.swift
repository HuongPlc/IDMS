//
//  File.swift
//  iDMS2018
//
//  Created by Huong on 7/15/21.
//  Copyright © 2021 IDMS2018. All rights reserved.
//

import Foundation

protocol Service {
    func saveInfo<T: Decodable>(info: T, forKey: String)
    func getInfo<T: Decodable>(for key: String) -> T?
}

struct ConfigInfoService: Service {
    static let shared = ConfigInfoService()

    private init() {
        
    }

    func saveInfo<T>(info: T, forKey: String) where T: Decodable {
        UserDefaults.standard.set(info, forKey: forKey)
    }

    func getInfo<T>(for key: String) -> T? where T: Decodable {
        guard let value = UserDefaults.standard.value(forKey: key) else {
            return nil
        }

        if let value = value as? T {
            return value
        }

        return nil
    }
}
