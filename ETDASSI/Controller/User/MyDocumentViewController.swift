//
//  MyDocumentViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 28/6/2564 BE.
//

import Foundation
import UIKit
import SwiftyJSON
import RealmSwift

class MyDocumentViewController: UIViewController {
    
    @IBOutlet weak var containerViewHeightCon: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    var listVC : VCDocument?
    var listVCDoc : [VCDocument] = []
    var realmDB = try! Realm()
    
    @IBOutlet weak var lblTagStatus: UILabel!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblDocumentName: UILabel!
    let BLUE_COLOR = UIColor(rgb: 0x40C2D3)
    let GREY_COLOR = UIColor(rgb: 0x9D9D9D)
    
    var selectedRow: String? = ""
    var selectedJWT: String? = ""
    
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var viewHead: UIView!
    @IBOutlet weak var lblTagTitle: UILabel!
    var vpDocumentName : String?
    
    var vpCIDSelectedRow: String? = ""
    
    var isCheckVP = false
    
    var rowSelectedCredentialFromMySignedView = ""
   // var selectedCredentialSubject:[JSON] = []
    var selectedCredentialSubject:JSON!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0x40C2D3), UIColor(rgb: 0x0A214A)], startPoint: .top, endPoint: .bottom)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        
        self.isCheckVP = false
        
       print("TestRowSelect :\(rowSelectedCredentialFromMySignedView)")
        if(rowSelectedCredentialFromMySignedView.isEmpty){
         
            let vcDoc = realmDB.objects(VCDocument.self)
            let vcDocByCid = vcDoc.filter("cid = %@", selectedRow ?? "")
            for item in vcDocByCid{
                listVCDoc.append(item)
            }
        
            lblDocumentName.text = listVCDoc.first?.type
            
            print("TestSelectRowListVC :\(listVCDoc)")
        
            if let tag =  listVCDoc.first?.tags , !tag.isEmpty {
                lblTagStatus.text = tag
            }else{
                lblTagStatus.text = "-"
            }
        
            if self.listVCDoc.first?.status == "active" {
                btnStatus.backgroundColor = BLUE_COLOR
            }else{
                btnStatus.setTitle("ถูกยกเลิก", for: .normal)
                btnStatus.backgroundColor = GREY_COLOR
            }
        
            listVC = listVCDoc.first
            
        }else{
        
            print("TestListVC :\(vpCIDSelectedRow)")
            if(vpCIDSelectedRow != ""){
                self.isCheckVP = true
                let vcDoc = realmDB.objects(VCDocument.self)
                let vc = vcDoc.filter("cid = %@", vpCIDSelectedRow ?? "").first
                
                lblDocumentName.text = vpDocumentName
                lblTagStatus.text = vc?.tags
                
                if vc?.status == "active"{
                    btnStatus.setTitle("ใช้งานได้", for: .normal)
                    btnStatus.backgroundColor = BLUE_COLOR
                }else{
                    btnStatus.setTitle("ถูกยกเลิก", for: .normal)
                    btnStatus.backgroundColor = GREY_COLOR
                }
            }else{
                lblDocumentName.text = vpDocumentName
            }
        }
     
        self.view.layoutIfNeeded()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if vpCIDSelectedRow != "" {
            let apiManager = APIManager()
            apiManager.getVCStatusList(cids: vpCIDSelectedRow!, onSuccess: { response in
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
            
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToLoadingQR" {
            let vc = segue.destination as! LoadingQRViewController
            
            vc.documentName = lblDocumentName.text ?? ""
        }
        
        if(rowSelectedCredentialFromMySignedView.isEmpty){
            
            if segue.identifier == "documentDetail" {
                let vc = segue.destination as! DocumentDetailViewController
                print("ContainerViewHeightCon")
                vc.listVC = listVC
       
                if(listVC != nil){
                    vc.payload = JWTManager.shared.getCredentialSchemaFromJWT(jwt: listVC!.jwt)
                }else{
                    vc.payload = JWTManager.shared.getCredentialSchemaFromJWT(jwt: selectedJWT!)
                }
                vc.updateTableViewHeight = { height in
                self.containerViewHeightCon.constant = height
                }
            }
        }else{
            if segue.identifier == "documentDetail" {
               
                let vc = segue.destination as! DocumentDetailViewController
                print("ContainerViewHeightCon")
                
                let dataDict = JWTManager.shared.getCredentialSchemaFromJWT(jwt: rowSelectedCredentialFromMySignedView).dictionaryValue
                
                for(key,value) in dataDict {
                    if key == "vc" {
                        let vcDict = value.dictionaryValue
                        for(key2,value2) in vcDict {
                        
                            if key2 == "credentialSubject" {
                                selectedCredentialSubject = JSON(rawValue: value2.rawValue) ?? ""

                            }
                        }
                    }
                }
                
                vc.selectedCredentialSubject = selectedCredentialSubject
                
                vc.updateTableViewHeight = { height in
                self.containerViewHeightCon.constant = height
                }
            }
        }
    }
    
    
    @IBAction func touchQRButton(_ sender: Any) {

        if listVCDoc.count > 0 {
            UserDefaults.standard.set(listVCDoc[0].cid, forKey: "CID")
        }
        
        
        if isCheckVP { // come from signeddocument
            UserDefaults.standard.set(vpCIDSelectedRow, forKey: "CID")
        }
       
//        self.performSegue(withIdentifier: "goToScanDocumentView", sender: nil)
        
        self.performSegue(withIdentifier: "goToLoadingQR", sender: nil)
    }
    
}

