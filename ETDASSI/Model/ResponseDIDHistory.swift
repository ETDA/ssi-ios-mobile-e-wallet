import Foundation
import SwiftyJSON

class ResponseDIDHistory {
    var _data : JSON
    
    init(data:JSON){
        _data = data
    }
    
    open var didDocument : [ResponseDIDVersion]{
        let didDocument = _data["did_document"].arrayValue
        var didList : [ResponseDIDVersion] = []
        for didData in didDocument {
            let keys = didData["VerificationMethod"].arrayValue
            var keyList : [VerificationKey] = []
            for keyData in keys {
                let key = VerificationKey(id: keyData["id"].stringValue,
                                            type: keyData["type"].stringValue,
                                            controller: keyData["controller"].stringValue,
                                            publicKeyPem: keyData["publicKeyPem"].stringValue)
                keyList.append(key)
            }
            
            let did = ResponseDIDVersion(id: didData["id"].stringValue,
                                      type: didData["type"].stringValue,
                                      controller: didData["controller"].stringValue,
                                      verificationKey: keyList,
                                      version: didData["version"].stringValue)
            didList.append(did)
        }
        
        return didList
    }
}
