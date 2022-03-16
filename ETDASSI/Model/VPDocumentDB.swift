import Foundation
import RealmSwift
import SwiftyJSON

class VPDocumentDB: Object{
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var verifierDid: String = ""
    @objc dynamic var createdAt: String = ""
    @objc dynamic var sendAt: String = ""
    @objc dynamic var vpIdList : String = ""
    @objc dynamic var jwt: String = ""
    @objc dynamic var sourceVP : String = ""
    
    
    static func get() -> [VPDocumentDB] {
        let realm = try! Realm()
         
        var documents: [VPDocumentDB] = []
        realm.objects(VPDocumentDB.self).forEach { document in
          documents.append(document)
        }

        return documents
    }
    
}

struct DataSourceVP : Codable{
    var id: String
    var requested_vp_id: String
    var requested_vp: RequestVP
    var holder: String
    var jwt: String
    var tags: String
    var document_count: Int
    var verify: Bool
    var created_at: String
    var updated_at: String
}

struct RequestVP : Codable {
    var id: String
    var name: String
    var status: String
    var schema_count: Int
    var created_at: String
    var updated_at: String
}

//class DataSourceVP{
//    var _data : JSON
//
//    init(data:JSON) {
//        _data = data
//    }
//
//    open var submitId : String{
//        return _data["id"].stringValue
//    }
//
//    open var requestedVPId : String{
//        return _data["requested_vp_id"].stringValue
//    }
//
//    open var requestVP : RequestVP{
//        return RequestVP(data: _data["requested_vp"])
//    }
//
//    open var holder : String{
//        return _data["holder"].stringValue
//    }
//
//    open var jwt : String{
//        return _data["jwt"].stringValue
//    }
//
//    open var tags : String{
//        return _data["tags"].stringValue
//    }
//
//    open var document_count : Int{
//        return _data["document_count"].intValue
//    }
//
//    open var verify : Bool{
//        return _data["verify"].boolValue
//    }
//
//    open var createdId : String{
//        return _data["created_at"].stringValue
//    }
//
//    open var updatedAt : String{
//        return _data["updated_at"].stringValue
//    }
//}
//
//class RequestVP{
//    var _data : JSON
//
//    init(data:JSON) {
//        _data = data
//    }
//
//    open var id : String{
//        return _data["id"].stringValue
//    }
//
//    open var name : String{
//        return _data["name"].stringValue
//    }
//
//    open var status : String{
//        return _data["status"].stringValue
//    }
//
//    open var schemaCount : Int{
//        return _data["schema_count"].intValue
//    }
//
//    open var createdAt : String{
//        return _data["created_at"].stringValue
//    }
//
//    open var updateAt : String{
//        return _data["updated_at"].stringValue
//    }
//}
