//
//  User.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 29/7/2564 BE.
//

import Foundation
import SwiftyJSON

class User {
    var firstName: String
    var lastName: String
    var email: String
    var devices: Device
    var registerDate: String
    
    init(data: JSON) {
        firstName = data["first_name"].stringValue
        lastName = data["last_name"].stringValue
        email = data["email"].stringValue
        devices = Device(data: data["device"])
        registerDate = data["registered_date"].stringValue
    }
}
