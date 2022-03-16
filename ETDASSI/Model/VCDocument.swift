import Foundation
import RealmSwift
import SwiftyJSON

class VCDocument: Object{
    @objc dynamic var cid: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var issuanceDate: String = ""
    @objc dynamic var expirationDate: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var issuer: String = ""
    @objc dynamic var holder: String = ""
    @objc dynamic var credentialSubject: String = ""
    @objc dynamic var jwt: String = ""
    @objc dynamic var backupStatus: Bool = false
    @objc dynamic var tags: String = ""
    var isReq: Bool = false
    var isSelect: Bool = false
    
    func reqSelect(){
        isSelect = true
    }
    
    
    
    public func updateStatus(cid: String, status: String, tags: String)  {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "cid = %@", cid)
        let document = try realm.objects(VCDocument.self).filter(predicate).first
        if tags == ""{
            try! realm.write {
                document?.status = status
            }
        }else{
            try! realm.write {
                document?.status = status
                document?.tags = tags
            }
        }
        
    }
//    val credentialSubject: List<VCAttributeModel>?,
    static func count() -> Int {
        let realm = try! Realm()
        
        let documents = realm.objects(VCDocument.self)

        return documents.count
    }
}


