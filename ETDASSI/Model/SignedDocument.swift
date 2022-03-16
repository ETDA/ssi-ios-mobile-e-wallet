//
//  SignedDocument.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 14/8/2564 BE.
//

import Foundation
import RealmSwift

class SignedDocument: Object {
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var body = ""
    @objc dynamic var message = ""
    @objc dynamic var creator = ""
    @objc dynamic var approveEndpoint = ""
    @objc dynamic var rejectEndpoint = ""
    
    @objc dynamic var jwt = ""
    @objc dynamic var created = Date()
    @objc dynamic var readStatus = false
    @objc dynamic var signingStatus = "APPROVED"
    

    static func add(notificationDoc: NotificationDocument, jwt: String) {
        let realm = try! Realm()
        
        try! realm.write() { // 2
            
            let document = SignedDocument()
            document.id = notificationDoc.id
            document.title = notificationDoc.title
            document.body = notificationDoc.body
            document.message = notificationDoc.message
            document.creator = notificationDoc.creator
            document.approveEndpoint = notificationDoc.approveEndpoint
            document.rejectEndpoint = notificationDoc.rejectEndpoint
            document.signingStatus = notificationDoc.signingStatus
            document.created = Date()
            document.jwt = jwt
            realm.add(document)
            
        }
        
    }
    
    public func updateStatus(id: String, status: String)  {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %@", id)
        let document = try realm.objects(SignedDocument.self).filter(predicate).first
        try! realm.write {
            document?.signingStatus = status
        }
    }
    
    public func updateRead(id: String)  {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %@", id)
        let document = try realm.objects(SignedDocument.self).filter(predicate).first
        try! realm.write {
            document?.readStatus = true
        }
    }
    
    static func get() -> [SignedDocument] {
        let realm = try! Realm()
        
        var documents: [SignedDocument] = []
        realm.objects(SignedDocument.self).forEach { document in
            documents.append(document)
        }

        return documents
    }
    
    static func getDates() -> [Date] {
        let realm = try! Realm()

        let dates = realm.objects(SignedDocument.self).reduce(into: [Date]()) { results, document in
            let date = document.created
            let beginningOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0))!
            let endOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))!
            //Only add the date if it doesn't exist in the array yet
            if !results.contains(where: { addedDate ->Bool in
                return addedDate >= beginningOfDay && addedDate <= endOfDay
            }) {
                results.append(beginningOfDay)
            }
        }

        return dates
    }
    
    static func getDocuments() -> [Date: Results<SignedDocument>]{
        let realm = try! Realm()
        
        let dates = realm.objects(SignedDocument.self).reduce(into: [Date]()) { results, document in
            let date = document.created
            let beginningOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0))!
            let endOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))!
            //Only add the date if it doesn't exist in the array yet
            if !results.contains(where: { addedDate -> Bool in
                return addedDate >= beginningOfDay && addedDate <= endOfDay
            }) {
                results.append(beginningOfDay)
            }
        }

        var groupedItems = [Date: Results<SignedDocument>]()
        groupedItems = dates.reduce(into: [Date: Results<SignedDocument>](), { results, date in
            let beginningOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0))!
            let endOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))!
            results[beginningOfDay] = realm.objects(SignedDocument.self).filter("created >= %@ AND created <= %@", beginningOfDay, endOfDay).sorted(byKeyPath: "created", ascending: false)
        })

        return groupedItems
    }
    
    static func unreadMessagesCount() -> Int {
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "readStatus == false")
        let documents = realm.objects(SignedDocument.self).filter(predicate)

        return documents.count
    }
    
    static func count() -> Int {
        let realm = try! Realm()
        
        let documents = realm.objects(SignedDocument.self)
        
        return documents.count
    }
}
