//
//  NotificationDocument.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 18/8/2564 BE.
//

import Foundation
import SwiftyJSON
import RealmSwift

class NotificationDocument: Object {
    @objc dynamic var messageId = ""
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var body = ""
    @objc dynamic var message = ""
    @objc dynamic var creator = ""
    @objc dynamic var approveEndpoint = ""
    @objc dynamic var rejectEndpoint = ""
    @objc dynamic var created = Date()
    @objc dynamic var readStatus = false
    @objc dynamic var signingStatus = "PENDING"
    
    static func add(json: JSON) {
        let realm = try! Realm()
        
        try! realm.write() {
            let document = NotificationDocument()
            document.title = json["title"].stringValue
            document.body = json["body"].stringValue
            document.message = json["message"].stringValue
            document.creator = json["creator"].stringValue
            document.approveEndpoint = json["approve_endpoint"].stringValue
            document.rejectEndpoint = json["reject_endpoint"].stringValue
            
            document.created = Date()
            document.readStatus = false
            document.signingStatus = "PENDING"
            document.id = UUID().uuidString
            realm.add(document)
        }
    }
    
    public func updateStatus(id: String, status: String)  {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %@", id)
        let document = try realm.objects(NotificationDocument.self).filter(predicate).first
        try! realm.write {
            document?.signingStatus = status
        }
    }
    
    public func updateRead(id: String)  {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %@", id)
        let document = try realm.objects(NotificationDocument.self).filter(predicate).first
        try! realm.write {
            document?.readStatus = true
        }
    }
    
    static func get() -> [NotificationDocument] {
        let realm = try! Realm()
        
        var documents: [NotificationDocument] = []
        realm.objects(NotificationDocument.self).forEach { document in
            documents.append(document)
        }

        return documents
    }
    
    static func getDatesPending() -> [Date] {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "signingStatus = %@", "PENDING")
        let dates = realm.objects(NotificationDocument.self).filter(predicate).reduce(into: [Date]()) { results, document in
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
    
    static func getPendingDocuments() -> [Date: Results<NotificationDocument>]{
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "signingStatus = %@", "PENDING")
        let dates = realm.objects(NotificationDocument.self).filter(predicate).reduce(into: [Date]()) { results, document in
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

        var groupedItems = [Date: Results<NotificationDocument>]()
        groupedItems = dates.reduce(into: [Date: Results<NotificationDocument>](), { results, date in
            let beginningOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0))!
            let endOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))!
            results[beginningOfDay] = realm.objects(NotificationDocument.self).filter(predicate).filter("created >= %@ AND created <= %@", beginningOfDay, endOfDay).sorted(byKeyPath: "created", ascending: false)
        })

        return groupedItems
    }
    
    static func getDates() -> [Date] {
        let realm = try! Realm()

        let dates = realm.objects(NotificationDocument.self).reduce(into: [Date]()) { results, document in
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
    
    static func getDocuments() -> [Date: Results<NotificationDocument>]{
        let realm = try! Realm()
        
        let dates = realm.objects(NotificationDocument.self).reduce(into: [Date]()) { results, document in
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

        var groupedItems = [Date: Results<NotificationDocument>]()
        groupedItems = dates.reduce(into: [Date: Results<NotificationDocument>](), { results, date in
            let beginningOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0))!
            let endOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))!
            results[beginningOfDay] = realm.objects(NotificationDocument.self).filter("created >= %@ AND created <= %@", beginningOfDay, endOfDay).sorted(byKeyPath: "created", ascending: false)
        })

        return groupedItems
    }
    
    static func unreadMessagesCount() -> Int {
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "readStatus == false")
        let documents = realm.objects(NotificationDocument.self).filter(predicate)

        return documents.count
    }
    
    static func readAll() {
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "readStatus == false")
        let documents = realm.objects(NotificationDocument.self).filter(predicate)
        print("There are \(documents.count) unread documents before updates")
        
        documents.forEach { document in
            try! realm.write {
                document.readStatus = true
            }
        }
    }
    static func getPendingDocumentCount() -> Int {
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "signingStatus = %@", "PENDING")
        let documents = realm.objects(NotificationDocument.self).filter(predicate)

        return documents.count
    }
}
