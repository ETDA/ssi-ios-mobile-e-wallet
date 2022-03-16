//
//  MyDocument.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 31/8/2564 BE.
//

import Foundation
import RealmSwift

class MyDocument: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var jwt = ""
    

    static func add(name: String) {
        let realm = try! Realm()
        
        try! realm.write() { // 2
            
            let newDoc = MyDocument()
            newDoc.name = name
            realm.add(newDoc)
            
        }
        
    }
    
    static func get(name: String) {
        let realm = try! Realm()
        
        
        let documents = realm.objects(MyDocument.self)
        
    }
    
}
