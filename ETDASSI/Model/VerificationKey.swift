import Foundation

class VerificationKey {
    var id: String
    var type: String
    var controller: String
    var publicKeyPem: String
    
    init(id:String, type:String, controller: String, publicKeyPem: String){
        self.id = id
        self.type = type
        self.controller = controller
        self.publicKeyPem = publicKeyPem
    }
}
