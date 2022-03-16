//
//  UserMainViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 15/6/2564 BE.
//

import Foundation
import RealmSwift
import UIKit

class UserMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var didLabel: UILabel!
    @IBOutlet weak var documentTableView: UITableView!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    @IBOutlet weak var myDocumentCount: UILabel!
    private var realmToken: NotificationToken?
    
    var cidCheck: [String] = []
    
    var cidSet = Set<String>()
    
    var listVCSelected : VCDocument?
    var realmDB = try! Realm()
    var listVCDoc : [VCDocument] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backImage = UIImage(named: "nav_back")!.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: 0, vertical: 0), for: .default)
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        UserManager.shared.isLogin = true
        didLabel.text = self.subAsDidAddress()
        updateMyDocumentCount()
        
        let pendingDocumentCount =  NotificationDocument.unreadMessagesCount()
        let signedDocumentCount = SignedDocument.unreadMessagesCount()
        
        let realm = try! Realm()
        let documents = try! realm.objects(NotificationDocument.self)
        realmToken = documents.observe { [weak self] changes in
            switch changes {
            case .update:
                self?.updateNotificationBadge()

            default:
                break
            }
        }
        self.documentTableView.reloadData()
    }
    
    func subAsDidAddress() -> String{
        let did = UserDefaults.standard.string(forKey: "DID_address") ?? ""
//        if did == "" {
//            return ""
//        }else{
//            print("DID : \(did) \n NAME : \(UserDefaults.standard.string(forKey: "first_name"))")
//            let index = did.index(did.startIndex, offsetBy: 12)
//            let index1 = did.index(did.endIndex, offsetBy: -4)
//            let substring = did[..<index]
//            let substring1 = did[index1...]
//            let subDid = "\(substring)xxxxxxxxxxxxx\(substring1)"
//            return subDid
//        }
        return did //return actual string without truncate string
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        updateNotificationBadge()
        updateMyDocumentCount()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//
//        realmToken?.invalidate()
//    }
    
    private func updateNotificationBadge() {
        let unreadCount = NotificationDocument.unreadMessagesCount()
        updateBadge(label: badgeLabel, count: unreadCount)
        badgeView.isHidden = unreadCount == 0
    }
    
    func updateBadge(label: UILabel, count: Int) {
        if count > 99 {
            label.text = "99+"
        } else {
            label.text = "\(count)"
        }
    }
    
    
    @IBAction func GotoVCScreen(_ sender: Any) {
        //self.performSegue (withIdentifier: "gotoVCScreen", sender: self)
        
        
        tabBarController?.selectedIndex  = 1
       
    }
    
    private func updateMyDocumentCount() {
        let documentCount = VCDocument.count()
//        myDocumentCount.text = "\(documentCount)"
      
       print("_mydoc_",documentCount)
      
        //============ remove duplicate VC========//
        let vcDoc = realmDB.objects(VCDocument.self)
        let vcDocs = vcDoc
    
        for item in vcDocs {
           
            if cidCheck.contains(item.cid.trimmingCharacters(in: .whitespaces)) {
                
            }else{
                cidCheck.append(item.cid.trimmingCharacters(in: .whitespaces))
                
                listVCDoc.append(item)
            }
        
        }
        
        myDocumentCount.text = "\(listVCDoc.count)"
        //===========================================//
  
        
    }
    @IBAction func touchRequestButton(_ sender: Any) {
        self.performSegue(withIdentifier: "goToRequestChoose", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("main", indexPath.row)
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MainDocumentTableViewCell
        
        cell.selectionStyle = .none
        
        if indexPath.row == 0{
           
            let documentCount  = NotificationDocument.getPendingDocumentCount()
            print("Pending",documentCount)
            cell.documentCountLabel.text = "\(documentCount)"
            cell.titleLabel.text = "เอกสารที่รอฉันลงนาม"
            cell.typeImageView.image = UIImage(named:"main_pending_documents")
            cell.messageLabel.numberOfLines = 2
            cell.messageLabel.text = "เอกสารที่ผู้อื่นทำการร้องขอเข้ามาให้เราลงรายมือชื่อดิจิทัลเพื่อ\nรับรองความถูกต้องของเอกสาร"
        }
        if indexPath.row == 1{
            let documentCount = SignedDocument.count()
            print("Sign",documentCount)
            cell.documentCountLabel.text = "\(documentCount)"
            
            cell.typeImageView.image = UIImage(named:"main_rejected_documents")
            cell.titleLabel.text = "เอกสารที่ฉันลงนามแล้ว"
            cell.messageLabel.text = "เอกสารที่ผู้อื่นทำการร้องขอเข้ามา โดยผ่านการลงลายมือดิจิทัลแล้ว"
        }
        
        print("cell", cell)
        return cell
    }
    
}
