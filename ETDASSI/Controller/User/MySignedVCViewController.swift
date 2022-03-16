//
//  MySignedVCViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 30/8/2564 BE.
//

import Foundation
import UIKit
import SwiftyJSON

class MySignedVCViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var requestDocumentContainerView: UIView!
    @IBOutlet weak var requestDocumentTableView: UITableView!
    
 
    var selectedName: String? = ""
    var selectedRow: String? = ""
    var selectedJWT: String? = ""
    var didValue : String? = ""
    var sendAtValue : String? = ""
    var listVPDoc : [VPDocumentDB] = []
    var idVPSelect : String? = ""
    
    @IBOutlet weak var lblDidTitle: UILabel!
    @IBOutlet weak var lblDateTimeTitle: UILabel!
    @IBOutlet weak var lblGroupDocument: UILabel!
    
    var data = [false, false]
    var lastSelectedRow: Int?
    
    var rowItem:[JSON] = []
    var typeArray:[JSON] = []
    var vpDocumentName : String?
    var vpCIDSelectedRow: String?
    
    var count : Int = 0
    
    var selectedCredentialSubject:[JSON] = []
    var rowSelectedCredential = ""
    
    var cidVP: [String] = []
    
    
    struct DecodedJWTStructure {
        let jti : String
        let nbf : String
        let vp :  String
        let type: String
        let aud : String
        let iss : String
        let context : String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        lblGroupDocument.text = selectedName
        lblDidTitle.text = didValue
        lblDateTimeTitle.text = convertDateFormater(sendAtValue ?? "")
       
   
        cidVP.removeAll()
        if let myVPID = idVPSelect, !myVPID.isEmpty {
            
            let result = idVPSelect!.components(separatedBy: ",")
            for i in result {
                cidVP.append(i)
            }
        }
        
        
//        for i in cidVP {
//            print("_item_",i)
//        }

        let decodedJWT = JWTManager.shared.getCredentialSchemaFromJWT(jwt: selectedJWT!).dictionaryValue
       
        
        for(key,value) in decodedJWT {
            print("_doc_0",key)
            print("_doc_1",value.rawValue)
            if key == "vp" {
                let vpDict = value.dictionaryValue
          
                for(key2,value2) in vpDict {
                    print("_doc_",value2.rawValue)
                    if key2 == "verifiableCredential" {
                        count = value2.arrayValue.count
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
                            //print("_value_",value2.arrayValue)
                            for (index3, value3) in value2.arrayValue.enumerated()
                            {
                                if index3 == 1 {
                                    typeArray.append(value3)
                                }
                            }
                        }
                        
                        if key2 == "credentialSubject" {
                      
                            selectedCredentialSubject.append(JSON(rawValue: value2.rawValue) ?? "")
                            
                           
                        }
                    }
                }
            }
            
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.title = "เอกสารที่รับการร้องขอ"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0x40C2D3), UIColor(rgb: 0x0A214A)], startPoint: .top, endPoint: .bottom)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
    }
    
    @IBAction func touchNextButton(_ sender: Any) {
        self.performSegue(withIdentifier: "goToComplete", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RequestedDocumentDetailTableviewCell
        
        cell.nameLabel?.text = self.typeArray[indexPath.row].stringValue
    
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        rowSelectedCredential = self.rowItem[indexPath.row].stringValue
        vpDocumentName = self.typeArray[indexPath.row].stringValue

        vpCIDSelectedRow = self.cidVP[indexPath.row]

        self.performSegue(withIdentifier: "goToDocumentView", sender: nil)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDocumentView" {
                 if let destVC = segue.destination as? MyDocumentViewController {
                      destVC.rowSelectedCredentialFromMySignedView = rowSelectedCredential
                     destVC.vpCIDSelectedRow = vpCIDSelectedRow
                    destVC.vpDocumentName = vpDocumentName

              }
        }
        
     
    }
    
}

