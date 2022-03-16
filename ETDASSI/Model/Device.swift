//
//  Device.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 29/7/2564 BE.
//

import Foundation
import SwiftyJSON

class Device {
    var model: String
    var uuid: String
    var osVersion: String
    var name: String
    var os: String
    
    init(data: JSON) {
        self.model = data["model"].stringValue
        self.uuid = data["uuid"].stringValue
        self.osVersion = data["os_version"].stringValue
        self.name = data["name"].stringValue
        self.os = data["os"].stringValue
    }
    
    static func deviceFromArray(datas: [JSON]) -> [Device] {
        var array = [Device]()
        for data in datas {
            array.append(Device(data: data))
        }
        return array
        
    }
    
}
