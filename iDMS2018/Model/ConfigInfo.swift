//
//  ConfigInfo.swift
//  iDMS2018
//
//  Created by Huong on 7/18/21.
//  Copyright © 2021 IDMS2018. All rights reserved.
//

import Foundation

class ConfigInfo: NSObject, Codable, NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(edms, forKey: "edms")
        coder.encode(companyCode, forKey: "companyCode")
    }

    required init?(coder: NSCoder) {
        edms = coder.decodeObject(forKey: "edms") as! String
        companyCode = coder.decodeObject(forKey: "companyCode") as! String
    }

    init(edms: String?, companyCode: String?) {
        self.edms = edms
        self.companyCode = companyCode
    }

    let edms: String?
    let companyCode: String?
}
