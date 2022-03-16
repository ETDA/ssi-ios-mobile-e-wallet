//
//  PendingDocument.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 18/8/2564 BE.
//

import Foundation
import RealmSwift

class PendingDocument: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var jwt = ""
    
    @objc dynamic var created = Date()
    @objc dynamic var readStatus = false
    

    static func add(name: String) {
        let realm = try! Realm()
        
        try! realm.write() { // 2
            
            let newDoc = PendingDocument()
            newDoc.name = name
            realm.add(newDoc)
            
        }
        
    }
    
    static func get() -> [PendingDocument] {
        let realm = try! Realm()
        
        var documents: [PendingDocument] = []
        realm.objects(PendingDocument.self).forEach { document in
            documents.append(document)
        }

        return documents
    }
    
    static func unreadMessagesCount() -> Int {
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "readStatus == false")
        let documents = realm.objects(PendingDocument.self).filter(predicate)

        return documents.count
    }
    
}
