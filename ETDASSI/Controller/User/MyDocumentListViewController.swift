//
//  MyDocumentListViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 23/6/2564 BE.
//

import Foundation
import UIKit
import Presentr
import SwiftyJSON
import RealmSwift

enum DocumentListMode: String {
    case myDocument, pendingDocument
}

class MyDocumentListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var myDocumentButton: UIButton!
    @IBOutlet weak var buttonIndicatorLeadingCon: NSLayoutConstraint!
    @IBOutlet weak var documentListTableView: UITableView!
    @IBOutlet weak var magnifierImageView: UIImageView!
    @IBOutlet weak var magnifierTrailingCon: NSLayoutConstraint!
    @IBOutlet weak var magnifierWidthCon: NSLayoutConstraint!
    
    var mode:DocumentListMode?
    let MAGNIFIER_WIDTH:CGFloat = 17.5
    let MAGNIFIER_TRAILING_CONSTANT:CGFloat = 6.0
    
    let BLUE_COLOR = UIColor(rgb: 0x40C2D3)
    let GREY_COLOR = UIColor(rgb: 0x9D9D9D)
    

    
    @IBOutlet weak var lblTotalDocument: UILabel!

    var listVCDoc : [VCDocument] = []
    var realmDB = try! Realm()
    var rowSelected : String?
    var jwtSelected : String?
    var listVCSelected : VCDocument?
    var rowSelectedName : String?
    
    var listVPDoc : [VPDocumentDB] = []
    var rowVPSelected : String?
    var jwtVPSelected : String?
    var vpVerifyDid : String?
    var vpSendAt : String?
    var vpDocumentName : String?
    var cidCheck: [String] = []
    
    let apiManager = APIManager()
    
    var idVPSelect : String?
    
    var cidSet = Set<String>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mode = .myDocument
        self.hideKeyboardWhenTappedAround()
        
        
        
        initialData()
        lblTotalDocument.text = String(listVCDoc.count)+" ฉบับ"

    }
    
    func initialData(){
        
        listVCDoc.removeAll()
        listVPDoc.removeAll()
        cidCheck.removeAll()
        
        let vcDocs = self.realmDB.objects(VCDocument.self)
        
        //===================VC=====================//
    
        for item in vcDocs{
            if self.cidCheck.contains(item.cid.trimmingCharacters(in: .whitespaces)) {
                
            }else{
                self.cidCheck.append(item.cid.trimmingCharacters(in: .whitespaces))
                
                self.listVCDoc.append(item)
            }
        
        }
        
        self.listVCDoc.reverse()
        
        //===================VP=====================//
        let vpDocs = VPDocumentDB.get()
        for item in vpDocs {
            listVPDoc.append(item)
            
        }
        
        listVPDoc.reverse()

       
    }
    


   
    
    func refreshActivity()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 , execute: {
            
            self.initialData()
            self.documentListTableView.reloadData()

        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            refreshActivity()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "เอกสารของฉัน"
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0x40C2D3), UIColor(rgb: 0x0A214A)], startPoint: .top, endPoint: .bottom)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        
        let vcDoc = realmDB.objects(VCDocument.self)
        var cids = ""
        for vc in vcDoc{
            if cids == "" {
                cids = vc.cid
            }
            else {
                cids = cids + "," + vc.cid
            }
        }
        
        apiManager.getVCStatusList(cids: cids, onSuccess: { response in
            for responseItem in response {
                var tags: String = ""
                let item = responseItem.1
                for tag in item["tags"].arrayValue{
                    if tags == ""{
                        tags = tag.stringValue
                    }else{
                        tags = tags + " " + tag.stringValue
                    }
                }
                VCDocument().updateStatus(cid: item["cid"].stringValue, status: item["status"].stringValue, tags: tags )
                
            }
        }, onFailure: { error in
            print(error)
        })
   
        print("_did_","ok")
        
      
   
    }
    
    @IBAction func touchMyDocumentButton(_ sender: Any) {
        self.buttonIndicatorLeadingCon.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        self.mode = .myDocument
        
       
        refreshActivity()
        self.lblTotalDocument.text = String(self.listVCDoc.count)+" ฉบับ"

        
    }
    
    @IBAction func touchPendingButton(_ sender: Any) {
        self.buttonIndicatorLeadingCon.constant = self.myDocumentButton.frame.width

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()

        }
        self.mode = .pendingDocument
        
      
        refreshActivity()
        self.lblTotalDocument.text = String(self.listVPDoc.count)+" ฉบับ"

       
    }
    
    @IBAction func touchFilterButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let filterVC = storyboard.instantiateViewController(withIdentifier: "FilterAlertViewController") as! FilterAlertViewController
        
        filterVC.touchDoneButton = { types in
            print(types)
            filterVC.dismiss(animated: true, completion: nil)
        }
        
        let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: Float(UIScreen.main.bounds.width) - 40), height: ModalSize.custom(size: 262.0), center: ModalCenterPosition.center))
        presenter.roundCorners = true
        presenter.cornerRadius = 8.0
        self.customPresentViewController(presenter, viewController: filterVC, animated: true, completion: nil)
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if mode == .myDocument {
            return listVCDoc.count
        }else{
            return listVPDoc.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if mode == .myDocument {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DocumentListTableViewCell
            cell.nameLabel?.text = self.listVCDoc[indexPath.row].type
            
            if self.listVCDoc[indexPath.row].status == "active" {
                cell.actionButton.setTitle("ใช้งานได้", for: .normal)
                cell.actionButton.backgroundColor = BLUE_COLOR
            }else{
                cell.actionButton.setTitle("ถูกยกเลิก", for: .normal)
                cell.actionButton.backgroundColor = GREY_COLOR
            }
          
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PendingCell", for: indexPath) as! PendingDocumentListTableViewCell
            
            print("_a_",self.listVPDoc[indexPath.row].name)
            
            let decodedJWT = JWTManager.shared.getCredentialSchemaFromJWT(jwt: listVPDoc[indexPath.row].jwt).dictionaryValue
            var rowItem:[JSON] = []
            var typeArray:[JSON] = []
            
            for(key,value) in decodedJWT {
                if key == "vp" {
                    let vpDict = value.dictionaryValue
                  
                    for(key2,value2) in vpDict {
                        if key2 == "verifiableCredential" {
                            rowItem = value2.arrayValue
                        }
                    }

                }
            }
            
            for row in rowItem {
                let dataDict = JWTManager.shared.getCredentialSchemaFromJWT(jwt: row.rawValue as! String).dictionaryValue
                
                for(key,value) in dataDict {
                    if key == "vc" {
                        let vcDict = value.dictionaryValue
                        for(key2,value2) in vcDict {
                            if key2 == "type" {
                             
                                for (index3, value3) in value2.arrayValue.enumerated()
                                {
                                    if index3 == 1 {
                                        typeArray.append(value3)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            cell.documentNameLabel?.text = "\(self.listVPDoc[indexPath.row].name)(\(typeArray.count))"
            
            
            if !self.listVPDoc[indexPath.row].createdAt.isEmpty {
                cell.dateLabel?.text = convertDateFormater(self.listVPDoc[indexPath.row].createdAt)
            }
    
            return cell
        }
    }
    
    func convertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        return  dateFormatter.string(from: date!)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mode == .myDocument {
            rowSelected = self.listVCDoc[indexPath.row].cid
            jwtSelected = self.listVCDoc[indexPath.row].jwt
            listVCSelected = self.listVCDoc[indexPath.row]
            self.performSegue(withIdentifier: "goToDocumentView", sender: nil)
        } else {
            rowSelectedName = self.listVPDoc[indexPath.row].name
            rowVPSelected = self.listVPDoc[indexPath.row].id
            jwtVPSelected = self.listVPDoc[indexPath.row].jwt
            vpVerifyDid = self.listVPDoc[indexPath.row].verifierDid
            vpSendAt = self.listVPDoc[indexPath.row].sendAt
            idVPSelect = self.listVPDoc[indexPath.row].vpIdList
            
            print("_id_",idVPSelect)
            
            self.performSegue(withIdentifier: "gotToMySignedVC", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDocumentView" {
                 if let destVC = segue.destination as? MyDocumentViewController {
                    destVC.selectedRow = rowSelected
                    destVC.selectedJWT = jwtSelected
                    destVC.listVC = listVCSelected
              }
        }
        
        if segue.identifier == "gotToMySignedVC" {
            if let destVP = segue.destination as? MySignedVCViewController {
                destVP.selectedName = rowSelectedName
                destVP.selectedRow = rowVPSelected
                destVP.selectedJWT = jwtVPSelected
                destVP.didValue = vpVerifyDid
                destVP.sendAtValue = vpSendAt
                destVP.idVPSelect = idVPSelect
           }
        }
    }

        
    
}

extension Array where Element: Hashable {
    func uniqued() -> Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}
