//
//  VPDocument.swift
//  ETDASSI
//
//  Created by Finema on 8/9/2564 BE.
//

import Foundation
import SwiftyJSON

class VPDocument{
    var _data:JSON
    
    init(data:JSON){
        _data = data
    }
    
    open var requestId : String {
        return _data["id"].stringValue
    }
    open var name : String {
        return _data["name"].stringValue
    }
    open var status : String {
        return _data["status"].stringValue
    }
    
    open var schemaCount : Int {
        return _data["schema_count"].intValue
    }
    open var createdAt : String {
        return _data["created_at"].stringValue
    }
    
    open var updatedAt : String {
        return _data["updated_at"].stringValue
    }
    open var verifierDid : String {
        return _data["verifier_did"].stringValue
    }
    
    open var endpoint : String {
        return _data["endpoint"].stringValue
    }
    
    open var verifier : String{
        return _data["verifier"].stringValue
    }
    
    open var vpRequest : [VpRequest] {
        let list = _data["schema_list"].arrayValue
        var vpReqList : [VpRequest] = []
        for vp in list {
            let key = VpRequest(id: vp["id"].stringValue, requestVPId: vp["requested_vp_id"].stringValue, type: vp["schema_type"].stringValue, isRequired: vp["is_required"].boolValue, note: vp["noted"].stringValue, createdAt: vp["created_at"].stringValue, updateAt: vp["updated_at"].stringValue)
            vpReqList.append(key)
        }
        
        return vpReqList
    }
}

class VpRequest {
    var id: String
    var requestVPId: String
    var type: String
    var isRequired: Bool
    var note : String
    var createdAt : String
    var updateAt : String
    var isSelect: Bool = false
    
    init(id:String, requestVPId:String, type:String, isRequired: Bool, note: String, createdAt:String, updateAt:String){
        self.id = id
        self.requestVPId = requestVPId
        self.type = type
        self.isRequired = isRequired
        self.note = note
        self.createdAt = createdAt
        self.updateAt = updateAt
    }
    
    func reqSelect(){
        isSelect = true
    }
}
