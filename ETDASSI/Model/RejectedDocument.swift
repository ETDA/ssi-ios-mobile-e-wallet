//
//  RejectedDocument.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 18/8/2564 BE.
//

import Foundation
import RealmSwift

class RejectedDocument: Object {
    
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var body = ""
    @objc dynamic var message = ""
    @objc dynamic var creator = ""
    @objc dynamic var approveEndpoint = ""
    @objc dynamic var rejectEndpoint = ""
    @objc dynamic var rejectReason = ""
    @objc dynamic var created = Date()
    @objc dynamic var readStatus = false
    

    static func add(notificationDoc: NotificationDocument, rejectReason: String) {
        let realm = try! Realm()
        
        try! realm.write() { // 2
            
            let document = RejectedDocument()
            document.id = notificationDoc.id
            document.title = notificationDoc.title
            document.body = notificationDoc.body
            document.message = notificationDoc.message
            document.creator = notificationDoc.creator
            document.approveEndpoint = notificationDoc.approveEndpoint
            document.rejectEndpoint = notificationDoc.rejectEndpoint
            document.rejectReason = rejectReason
            document.created = Date()
            realm.add(document)
            
        }
        
    }
    
    public func updateRead(id: String)  {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "id = %@", id)
        let document = try realm.objects(RejectedDocument.self).filter(predicate).first
        try! realm.write {
            document?.readStatus = true
        }
    }
    
    static func get() -> [RejectedDocument] {
        let realm = try! Realm()
        
        var documents: [RejectedDocument] = []
        realm.objects(RejectedDocument.self).forEach { document in
            documents.append(document)
        }

        return documents
    }
    
    static func getDates() -> [Date] {
        let realm = try! Realm()

        let dates = realm.objects(RejectedDocument.self).reduce(into: [Date]()) { results, document in
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
    
    static func getDocuments() -> [Date: Results<RejectedDocument>]{
        let realm = try! Realm()
        
        let dates = realm.objects(RejectedDocument.self).reduce(into: [Date]()) { results, document in
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

        var groupedItems = [Date: Results<RejectedDocument>]()
        groupedItems = dates.reduce(into: [Date: Results<RejectedDocument>](), { results, date in
            let beginningOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 0, minute: 0, second: 0))!
            let endOfDay = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date), month: Calendar.current.component(.month, from: date), day: Calendar.current.component(.day, from: date), hour: 23, minute: 59, second: 59))!
            results[beginningOfDay] = realm.objects(RejectedDocument.self).filter("created >= %@ AND created <= %@", beginningOfDay, endOfDay).sorted(byKeyPath: "created", ascending: false)
        })

        return groupedItems
    }
    
    static func unreadMessagesCount() -> Int {
        let realm = try! Realm()
        
        let predicate = NSPredicate(format: "readStatus == false")
        let documents = realm.objects(RejectedDocument.self).filter(predicate)

        return documents.count
    }
    
}
