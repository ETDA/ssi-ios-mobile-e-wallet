import Foundation
import SwiftyJSON

class ResponseDID {
    var _data:JSON
    
    init(data:JSON){
        _data = data
    }
    
    open var idDID : String {
        return _data["id"].stringValue
    }
    
    open var context : String {
        return _data["@context"].stringValue
    }
    
    open var controller : String {
        return _data["controller"].stringValue
    }
    
    open var recovery : String {
        return _data["recoverer"].stringValue
    }
    
    open var verificationMethods : [VerificationKey] {
        let keys = _data["verificationMethod"].arrayValue
        var keyList : [VerificationKey] = []
        for keyData in keys {
            let key = VerificationKey(id: keyData["id"].stringValue,
                                      type: keyData["type"].stringValue,
                                      controller: keyData["controller"].stringValue,
                                      publicKeyPem: keyData["publicKeyPem"].stringValue)
            keyList.append(key)
        }
        
        return keyList
    }
}
