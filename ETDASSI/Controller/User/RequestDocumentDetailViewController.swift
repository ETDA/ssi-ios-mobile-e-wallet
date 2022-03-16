//
//  RequestDocumentDetailViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 28/6/2564 BE.
//

import Foundation
import UIKit
import SwiftyJSON
import RealmSwift
import KRProgressHUD

class RequestDocumentDetailViewController:UIViewController, UITableViewDelegate, UITableViewDataSource, ReqDocDelegate {
    
    
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var requestDocumentContainerView: UIView!
    @IBOutlet weak var requestDocumentTableView: UITableView!
    @IBOutlet weak var requestDocumentLabel: UILabel!
    @IBOutlet weak var didLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var verifyByLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    let apiManager = APIManager()
    var callAPI : APIManager?
    var dataVP : VPDocument?
//    var data = [false , false]
    var listDataVPReq : [VpRequest] = []
    var listVCDoc : [VCDocument] = []
    var lastSelectedRow: Int?
    var did: String?
    var dateTime : String?
    var realmDB = try! Realm()
    var listSelect : [VCDocument] = []
    var countReq : Int = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callAPI = APIManager()
        
        nextButton.backgroundColor = UIColor(rgb: 0xD0D0D0)
        
        self.navigationItem.hidesBackButton = true
        
        let backImage = UIImage(named: "nav_back")!.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(popVC(sender:)))
        backButton.image = backImage
        self.navigationItem.leftBarButtonItem = backButton
        
        let vcDoc = realmDB.objects(VCDocument.self)
        if(dataVP != nil){
            listDataVPReq = dataVP!.vpRequest
            did = dataVP!.verifierDid
            dateTime = shortDateTime(dateStr: dataVP!.createdAt)
            
            didLabel.text = did
            dateLabel.text = dateTime
            verifyByLabel.text = dataVP?.verifier
            nameLabel.text = dataVP?.name
            
            for vpI in listDataVPReq{
                if(vpI.isRequired){
                    countReq = countReq + 1
                }
            }
            
//            for vpI in listDataVPReq{
//                let vcDocByCid = vcDoc.filter("type = %@", vpI.type)
//
//                if vcDocByCid.first != nil { // check nil for bug
//                    let vc = vcDocByCid.first!
//                    if(vpI.isRequired){
//                        vc.isReq = true
//                    }
//                    listVCDoc.append(vc)
//
//                }
//            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "เอกสารที่รับการร้องขอ"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0xFBB617), UIColor(rgb: 0xFB9317)], startPoint: .top, endPoint: .bottom)
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
    }
    
    @objc
    func popVC(sender: UIBarButtonItem) {
        print("Need GO")
        performSegue(withIdentifier: "vpDetailGoToMain", sender: nil)
    }
    
    @IBAction func touchNextButton(_ sender: Any) {
        self.sendVP()
        
    }
    
    func sendVP(){
//        for vc in listVCDoc {
//            if(vc.isSelect){
//                listSelect.append(vc)
//            }
//        }
       
        
        if(listSelect.count > 0){
            nextButton.isEnabled = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.callAPI?.createVP(listVC: self.listSelect,dataVP: self.dataVP!, onSuccess: { responseBool in
                    self.nextButton.isEnabled = true
                        if(responseBool){
                            self.performSegue(withIdentifier: "goToComplete", sender: self.dataVP!)
                        }else{
                            KRProgressHUD.showError(withMessage: "ไม่สามารถส่งเอกสารสำแดงได้")
                        }
                    }, onFailure: { errorResponse in
                        self.nextButton.isEnabled = true
                        KRProgressHUD.showError(withMessage: errorResponse.message)
                        
                    })
            }
            
        }else{
            print("No Data In Seleect")
        }
//        self.callAPI?.createVP()
    }
    
    func selectlistVC(_ vc: VCDocument) {
        if(listSelect.isEmpty){
            listSelect.append(vc)
        }else{
            var countSelect:Int = 0
            for vcSelect in listSelect{
                if(vcSelect.type == vc.type){
                    listSelect.remove(at: countSelect)
                    break
                }
                countSelect = countSelect + 1
            }
            listSelect.append(vc)
        }
        
        print("Check Data selectlistVC :\(listSelect)")
        
    }
    
    @IBAction func unwindToRequestDocument( _ seg: UIStoryboardSegue) {
        if let row = lastSelectedRow {
//            listVCDoc[row].reqSelect()
            listDataVPReq[row].reqSelect()
        }
        
//        if listVCDoc.allSatisfy({$0.isSelect}) {
        if listDataVPReq.allSatisfy({$0.isSelect}) {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor(rgb: 0xA214A)
            requestDocumentContainerView.backgroundColor = UIColor(rgb: 0x02C39E)
            requestDocumentLabel.textColor = .white
        }else if(lastSelectedRow != nil){
//            if(listVCDoc[lastSelectedRow!].isReq){
            if countReq > 0 {
                print("Check Data List Select :\(listSelect)")
                if listSelect.isEmpty{
                    nextButton.isEnabled = false
                    nextButton.backgroundColor = UIColor(rgb: 0xD0D0D0)
                    requestDocumentContainerView.backgroundColor = UIColor(rgb: 0xEBF5F7)
                    requestDocumentLabel.textColor = UIColor(rgb: 0xA214A)
                }else{
                    var countSelectReq:Int = 0
                    for vcS in listSelect {
                        if(vcS.isReq){
                            countSelectReq = countSelectReq + 1
                        }
                    }
                    if countSelectReq >= countReq {
                        nextButton.isEnabled = true
                        nextButton.backgroundColor = UIColor(rgb: 0xA214A)
                        requestDocumentContainerView.backgroundColor = UIColor(rgb: 0x02C39E)
                        requestDocumentLabel.textColor = .white
                    }else{
                        nextButton.isEnabled = false
                        nextButton.backgroundColor = UIColor(rgb: 0xD0D0D0)
                        requestDocumentContainerView.backgroundColor = UIColor(rgb: 0xEBF5F7)
                        requestDocumentLabel.textColor = UIColor(rgb: 0xA214A)
                    }
                }
            }else{
                nextButton.isEnabled = true
                nextButton.backgroundColor = UIColor(rgb: 0xA214A)
                requestDocumentContainerView.backgroundColor = UIColor(rgb: 0x02C39E)
                requestDocumentLabel.textColor = .white
            }
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor(rgb: 0xD0D0D0)
            requestDocumentContainerView.backgroundColor = UIColor(rgb: 0xEBF5F7)
            requestDocumentLabel.textColor = UIColor(rgb: 0xA214A)
        }
        requestDocumentTableView.reloadData()
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return listVCDoc.count
        return listDataVPReq.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
//        self.performSegue(withIdentifier: "gotToChooseDocument", sender: listVCDoc[indexPath.row])
        self.performSegue(withIdentifier: "gotToChooseDocument", sender: listDataVPReq[indexPath.row])
        lastSelectedRow = indexPath.row
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotToChooseDocument"{
            let destination = segue.destination as? ChooseDocumentViewController
            destination?.dataVPReq = sender as? VpRequest
            destination?.delegate = self
            
//            destination?.dataVcDocument = sender as? VCDocument
        }
        if segue.identifier == "goToComplete"{
            let destination = segue.destination as? CompleteVPViewController
            destination?.vpDoc = sender as? VPDocument
            destination?.listVCDoc = listSelect
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RequestedDocumentDetailTableviewCell
//        if data[indexPath.row] {
        
//        if listVCDoc[indexPath.row].isSelect{
//            cell.checkImageTralingCon.constant = 10
//            cell.checkImageViewWidthCon.constant = 20
//            cell.checkImageView.isHidden = false
//            cell.nameLabel.text = listVCDoc[indexPath.row].type
//        } else {
//            cell.checkImageTralingCon.constant = 0
//            cell.checkImageViewWidthCon.constant = 0
//            cell.checkImageView.isHidden = true
//
//        }
//        cell.nameLabel.text = listVCDoc[indexPath.row].type
        if listDataVPReq[indexPath.row].isSelect{
            cell.checkImageTralingCon.constant = 10
            cell.checkImageViewWidthCon.constant = 20
            cell.checkImageView.isHidden = false
            cell.nameLabel.text = listDataVPReq[indexPath.row].type
        } else {
            cell.checkImageTralingCon.constant = 0
            cell.checkImageViewWidthCon.constant = 0
            cell.checkImageView.isHidden = true
        }
        cell.nameLabel.text = listDataVPReq[indexPath.row].type
        
        return cell
    }
    
}

protocol ReqDocDelegate: class {
    func selectlistVC(_ vc: VCDocument)
}

func shortDateTime(dateStr:String) -> String?{
    let dateFormatterGet = DateFormatter()
    dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    dateFormatterGet.timeZone = TimeZone(abbreviation: "UTC")
    
    if let datePrint = dateFormatterGet.date(from: dateStr){
        dateFormatterGet.timeZone = TimeZone.current
        dateFormatterGet.dateFormat = "dd MMM yyyy เวลา HH:mm"
        print(dateStr)
        return dateFormatterGet.string(from: datePrint)
    }
    
    return dateStr
}
