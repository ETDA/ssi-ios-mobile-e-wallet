//
//  VerifyVCViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 31/8/2564 BE.
//

import Foundation
import UIKit
import SwiftyJSON
import RealmSwift
class VerifyVCViewController: UIViewController {
    
    var jsonVerify : JSON?
    var jwt: String? = ""
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeightCon: NSLayoutConstraint!
    @IBOutlet weak var imgViewChecker: UIImageView!
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var lblDocumentName: UILabel!
   
 
   
   
    let BLUE_COLOR = UIColor(rgb: 0x40C2D3)
    let GREY_COLOR = UIColor(rgb: 0x9D9D9D)
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lblIssuerDocumentDate: UILabel!
    
    @IBOutlet weak var lbl2: UILabel!
    @IBOutlet weak var lblIssuerDocumentName: UILabel!
    
    @IBOutlet weak var lbl3: UILabel!
    @IBOutlet weak var lblExpiredDate: UILabel!
    
    @IBOutlet weak var lbl4: UILabel!
    @IBOutlet weak var lblHolderDocumentName: UILabel!
    
    var realmDB = try! Realm()
    var listVCDoc : [VCDocument] = []
    var listVC : VCDocument?
    
    var keys = [String]()
    var values = [JSON]()
    var keyDetail = [String]()
    var valueDetail = [JSON]()
    var valueDetailStr = [String]()
    
    var final_key = [String]()
    var final_value = [String]()
    
    var arrData:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if ((jsonVerify?["verification_result"].boolValue) == true) {
            imgViewChecker.image = UIImage(named: "complete_check")
        } else{
            imgViewChecker.image =  UIImage(named: "close_button")
        }
        
//        if let issuerDate =  jsonVerify?["issuance_date"].stringValue , !issuerDate.isEmpty
//        {
//            lblIssuerDocumentDate.text = convertDateFormater(arrData[0]["issuance_date"].stringValue)
//        }
        
        
        
        //................ Show Document............//
        
        
        if !arrData.isEmpty{
            
            let typeData:[JSON] = arrData[0]["type"].arrayValue
            if typeData.count > 1 {
                lblDocumentName.text = typeData[1].stringValue
            }else{
                lblDocumentName.text = "-"
            }
        
            if arrData[0]["status"].stringValue == "active" {
                btnStatus.backgroundColor = BLUE_COLOR
                btnStatus.setTitle("ใช้งานได้", for: .normal)
            }else{
                btnStatus.backgroundColor = GREY_COLOR
                btnStatus.setTitle("ถูกยกเลิก", for: .normal)
            }
        }
        
        
        //..................End....................//
       
        

        
    }
    func convertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        return  dateFormatter.string(from: date!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func touchBackToMainButton(_ sender: Any) {
//        self.navigationController?.popToRootViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "vpGoToMain", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
            if segue.identifier == "documentDetail" {
                let vc = segue.destination as! DocumentDetailViewController
                print("ContainerViewHeightCon")
                
                if( jsonVerify != nil){
                    arrData = jsonVerify!["vc"].arrayValue
                    let vcDoc = realmDB.objects(VCDocument.self)
                    let vcDocByCid = vcDoc.filter("cid = %@", arrData[0]["cid"].stringValue )
                    for item in vcDocByCid{
                        listVCDoc.append(item)
                    }

                    for item in listVCDoc {
                        print("_ve_2",item.type)
                    }
                    
                    listVC = listVCDoc.first
                }
                
//                vc.listVC = listVC
                
                if(listVC != nil){
                    print("_ve_xx","not nil")
                    vc.payload = JWTManager.shared.getCredentialSchemaFromJWT(jwt: listVC!.jwt)
                }else{
                    if(jwt != ""){
                        let jwtCredential = JWTManager.shared.getCredentialSchemaFromJWT(jwt: jwt!)
                        let vp = jwtCredential["vp"]
                        let verifiableCredential = vp["verifiableCredential"]
                        for vpVerify in verifiableCredential.arrayValue{
                            let jwtVerify = vpVerify.stringValue
                            print("JWT payload: \(jwtVerify)")
                            vc.payload = JWTManager.shared.getCredentialSchemaFromJWT(jwt: jwtVerify)
                            break
                        }
                    }else{
                        vc.payload = JWTManager.shared.getCredentialSchemaFromJWT(jwt: JWTManager().testJWT)
                    }
                }
                vc.updateTableViewHeight = { height in
                    self.containerViewHeightCon.constant = height
                }
            }
         
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
