import Foundation
import SwiftyJSON

class ResponseDIDVersion{
    var id : String
    var context : String
    var controller : String
    var verificationKey : [VerificationKey]
    var version : String
    
    init(id:String, type:String, controller: String, verificationKey: [VerificationKey], version:String){
        self.id = id
        self.context = type
        self.controller = controller
        self.verificationKey = verificationKey
        self.version = version
    }
}
