import Foundation
import SwiftyJSON

class ResponseJWT {
    var _data:JSON
    
    init(data:JSON){
        _data = data
    }
    
    open var idDID : String {
        return _data["sender_did"].stringValue
    }
    
    open var created_at : String {
        return _data["created_at"].stringValue
    }
    
    open var vcsList : [String] {
        let keys = _data["vcs"].arrayValue
        var keyList : [String] = []
        for keyData in keys {
            
            keyList.append(keyData.rawValue as! String)
        }
        
        return keyList
    }
}
