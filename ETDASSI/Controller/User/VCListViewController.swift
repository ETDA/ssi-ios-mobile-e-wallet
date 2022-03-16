//
//  VCListViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 28/6/2564 BE.
//

import Foundation
import RealmSwift
import UIKit

enum SignedDocumentMode: String {
    case pending, denied, signed
}

class VCListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var pendingSignButton: UIButton!
    @IBOutlet weak var buttonIndicatorLeadingCon: NSLayoutConstraint!
    @IBOutlet weak var catagoryScrollView: UIScrollView!
    @IBOutlet weak var signDocumentListTableView: UITableView!
    @IBOutlet weak var smallScrollViewIndicator: UIView!
    @IBOutlet weak var smallScrollViewIndicatorLeadingCon: NSLayoutConstraint!
    @IBOutlet weak var magnifierImageView: UIImageView!
    @IBOutlet weak var magnifierTrailingCon: NSLayoutConstraint!
    @IBOutlet weak var magnifierWidthCon: NSLayoutConstraint!

    @IBOutlet weak var rejectedBadge: UIView!
    @IBOutlet weak var rejectedBadgeLabel: UILabel!
    @IBOutlet weak var signBadge: UIView!
    @IBOutlet weak var signedBadgeLabel: UILabel!
    @IBOutlet weak var pendingBadgeLabel: UILabel!
    @IBOutlet weak var pendingBadge: UIView!
    var isPendingDocumentMode = true
    var mode: SignedDocumentMode = .pending
    let MAGNIFIER_WIDTH:CGFloat = 17.5
    let MAGNIFIER_TRAILING_CONSTANT:CGFloat = 6.0
    
    @IBOutlet weak var lblTotalDocument: UILabel!
    
    
    
    private var dates1: [Date] = []
    private var dates2: [Date] = []
    private var dates3: [Date] = []
    private var groupedDocument: [Date: Results<NotificationDocument>] = [:]
    private var signedDocument : [Date: Results<SignedDocument>] = [:]
    private var rejectDocument : [Date: Results<RejectedDocument>] = [:]
    private let dateFormatter = DateFormatter()
    
    var documentNameForDeniedTab: String? = ""
    
    var documentNameForSignedTab: String? = ""
    var documentCreatedDateForSignedTab: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        dates1 = NotificationDocument.getDatesPending()
        groupedDocument = NotificationDocument.getPendingDocuments()
        dates2 = RejectedDocument.getDates()
        rejectDocument = RejectedDocument.getDocuments()
        dates3 = SignedDocument.getDates()
        signedDocument = SignedDocument.getDocuments()
        
        let notiCount =  NotificationDocument.unreadMessagesCount()
        let signCount = SignedDocument.unreadMessagesCount()
        let rejectCount = RejectedDocument.unreadMessagesCount()
        
        
        
    
        
        self.updateBadge(badgeView: pendingBadge,badgeLabel: pendingBadgeLabel, count: notiCount)
        self.updateBadge(badgeView: signBadge,badgeLabel: signedBadgeLabel, count: signCount)
        self.updateBadge(badgeView: rejectedBadge,badgeLabel: rejectedBadgeLabel, count: rejectCount)
        
        dateFormatter.calendar = Calendar(identifier: .buddhist)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC+07")
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "th")
        dateFormatter.dateFormat = "d MMM yy เวลา HH:mm"
        
        self.signDocumentListTableView.reloadData()
        
      
        lblTotalDocument.text = String(groupedDocument.count) + " ฉบับ"
      
        
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "เอกสารที่ลงนาม"
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0xFBB617), UIColor(rgb: 0xFB9317)], startPoint: .top, endPoint: .bottom)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        
        dates1 = NotificationDocument.getDatesPending()
        dates1.reverse()
        groupedDocument = NotificationDocument.getPendingDocuments()
        
        
        dates2 = RejectedDocument.getDates()
        dates2.reverse()
        rejectDocument = RejectedDocument.getDocuments()
        
        
        dates3 = SignedDocument.getDates()
        dates3.reverse()
        signedDocument = SignedDocument.getDocuments()
        
        
        
      

        self.signDocumentListTableView.reloadData()
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToComplete" {
            let destinationVC = segue.destination as! CompleteViewController
            destinationVC.mode = .extra
//            destinationVC.documentMode = .detail
        }
        
        if segue.identifier == "goToPendingApprove"{
            let destinationVC = segue.destination as! PendingApproveViewController
            destinationVC.notificationDocument = sender as? NotificationDocument
        }
        
        if segue.identifier == "goToDenyDocument"{
            let destinationVC = segue.destination as! DeniedDocumentViewController
            destinationVC.documentName = documentNameForDeniedTab
            
            destinationVC.notificationDocument = sender as? RejectedDocument
        }
        
        if segue.identifier == "goToSigned"{
            let destinationVC = segue.destination as! SignedDocumentViewController
            destinationVC.documentName = documentNameForSignedTab
            destinationVC.documentCreatedDate = documentCreatedDateForSignedTab
            destinationVC.notificationDocument = sender as? SignedDocument
        }
        
        
    }
    
    func updateBadge(badgeView: UIView,badgeLabel: UILabel, count: Int) {
        if count > 0 {
            if count > 99 {
                badgeLabel.text = "99+"
            } else {
                badgeLabel.text = "\(count)"
            }
        }else{
            badgeView.isHidden = true
        }
        
    }
    
    @IBAction func touchPendingSignButton(_ sender: Any) {
        mode = .pending
        self.buttonIndicatorLeadingCon.constant = 0
        self.smallScrollViewIndicatorLeadingCon.constant = 0
        catagoryScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        groupedDocument = NotificationDocument.getPendingDocuments()
    
        
        self.isPendingDocumentMode = true
        self.signDocumentListTableView.reloadData()
        
        lblTotalDocument.text = String(groupedDocument.count) + " ฉบับ"
  
        

    }
    
    @IBAction func touchDeniedSignButton(_ sender: Any) {
        mode = .denied
        self.buttonIndicatorLeadingCon.constant = self.pendingSignButton.frame.width
        self.smallScrollViewIndicatorLeadingCon.constant = smallScrollViewIndicator.frame.width / 2.0
        let maxScrollWidth = catagoryScrollView.contentSize.width - UIScreen.main.bounds.width > UIScreen.main.bounds.width ? self.pendingSignButton.frame.width : catagoryScrollView.contentSize.width - UIScreen.main.bounds.width
        catagoryScrollView.setContentOffset(CGPoint(x: maxScrollWidth, y: 0), animated: true)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        rejectDocument = RejectedDocument.getDocuments()
        
      
        self.isPendingDocumentMode = true
        self.signDocumentListTableView.reloadData()
        
    
     
        lblTotalDocument.text = String(rejectDocument.count) + " ฉบับ"
    
    }
    
    @IBAction func touchSignedButton(_ sender: Any) {
        mode = .signed
        self.buttonIndicatorLeadingCon.constant = (self.pendingSignButton.frame.width * 2)
        self.smallScrollViewIndicatorLeadingCon.constant = smallScrollViewIndicator.frame.width
        let maxScrollWidth = catagoryScrollView.contentSize.width - UIScreen.main.bounds.width
        catagoryScrollView.setContentOffset(CGPoint(x: maxScrollWidth, y: 0), animated: true)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()

        }
        
        signedDocument = SignedDocument.getDocuments()
       
        
        self.isPendingDocumentMode = false
        self.signDocumentListTableView.reloadData()
        
        lblTotalDocument.text = String(signedDocument.count) + " ฉบับ"

    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.text == "" {
            magnifierImageView.isHidden = false
            magnifierTrailingCon.constant = MAGNIFIER_TRAILING_CONSTANT
            magnifierWidthCon.constant = MAGNIFIER_WIDTH
        } else {
            magnifierImageView.isHidden = true
            magnifierTrailingCon.constant = 0
            magnifierWidthCon.constant = 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if mode == .pending {
            return groupedDocument.keys.count
        }else if mode == .denied {
            return rejectDocument.keys.count
        } else if mode == .signed {
            return signedDocument.keys.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if mode == .pending {
            if (dates1.count > section){
                let date = dates1[section]
                return groupedDocument[date]?.count ?? 0
            }else{
                return 0
            }
            
        } else if mode == .denied {
            if (dates2.count > section){
                let date = dates2[section]
                return rejectDocument[date]?.count ?? 0
            }else{
                return 0
            }
        } else if mode == .signed {
            if (dates3.count > section){
                let date = dates3[section]
                return signedDocument[date]?.count ?? 0
            }else{
                return 0
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PendingDocumentListTableViewCell
        
        
   
        
        if mode == .pending {
            let date = dates1[indexPath.section]
            let document = groupedDocument[date]![indexPath.row]
            let json = JWTManager.shared.getHeaderFromJWT(jwt: document.message)
            let vcMessage = json["vc"]
            
            let decoder = JSONDecoder()
            let model = try! decoder.decode(CredentialVCDetail.self, from:vcMessage.rawData())
            cell.documentNameLabel.text = model.type[1]
            cell.dateLabel.text = dateFormatter.string(from: document.created)
            if document.readStatus {
                cell.dotImageView.isHidden = true
                cell.backgroundColor = .clear
            }else{
                cell.dotImageView.isHidden = false
                cell.backgroundColor = UIColor(rgb: 0xEBF5F7)
            }
        } else if mode == .denied {
            let date = dates2[indexPath.section]
            let document = rejectDocument[date]![indexPath.row]
            let json = JWTManager.shared.getHeaderFromJWT(jwt: document.message)
            let vcMessage = json["vc"]
            
            let decoder = JSONDecoder()
            let model = try! decoder.decode(CredentialVCDetail.self, from:vcMessage.rawData())
            cell.documentNameLabel.text = model.type[1]
            
            cell.dateLabel.text = dateFormatter.string(from: document.created)
            if document.readStatus {
                cell.dotImageView.isHidden = true
                cell.backgroundColor = .clear
            }else{
                cell.dotImageView.isHidden = false
                cell.backgroundColor = UIColor(rgb: 0xEBF5F7)
            }
        } else if mode == .signed {
            let date = dates3[indexPath.section]
            let document = signedDocument[date]![indexPath.row]
            let json = JWTManager.shared.getHeaderFromJWT(jwt: document.message)
            let vcMessage = json["vc"]
            print("dataJson \(json)")
            let decoder = JSONDecoder()
            let model = try! decoder.decode(CredentialVCDetail.self, from:vcMessage.rawData())
            cell.documentNameLabel.text = model.type[1]
            cell.dateLabel.text = dateFormatter.string(from: document.created)
            if document.readStatus {
                cell.dotImageView.isHidden = true
                cell.backgroundColor = .clear
            }else{
                cell.dotImageView.isHidden = false
                cell.backgroundColor = UIColor(rgb: 0xEBF5F7)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if mode == .pending {
            let date = dates1[indexPath.section]
            let document = groupedDocument[date]![indexPath.row]
            NotificationDocument().updateRead(id: document.id)
            
            performSegue(withIdentifier: "goToPendingApprove", sender: document)

        } else if mode == .denied {
            let date = dates2[indexPath.section]
            let document = rejectDocument[date]![indexPath.row]
            
            
            
        
            let json = JWTManager.shared.getHeaderFromJWT(jwt: document.message)
            let vcMessage = json["vc"]
            let decoder = JSONDecoder()
            let model = try! decoder.decode(CredentialVCDetail.self, from:vcMessage.rawData())
            documentNameForDeniedTab = model.type[1]
        
            
            RejectedDocument().updateRead(id: document.id)
            performSegue(withIdentifier: "goToDenyDocument", sender: document)

        } else if mode == .signed {
            let date = dates3[indexPath.section]
            let document = signedDocument[date]![indexPath.row]
            
            
            let json = JWTManager.shared.getHeaderFromJWT(jwt: document.message)
            let vcMessage = json["vc"]
            let decoder = JSONDecoder()
            let model = try! decoder.decode(CredentialVCDetail.self, from:vcMessage.rawData())
            documentNameForSignedTab = model.type[1]
            
            documentCreatedDateForSignedTab = dateFormatter.string(from: document.created)
     
      
            print("print DOC sign \(document)")
            SignedDocument().updateRead(id: document.id)
            performSegue(withIdentifier: "goToSigned", sender: document)
        }

        
    }
    
}

