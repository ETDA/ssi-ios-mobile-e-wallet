//
//  GetVCFromQRViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 30/8/2564 BE.
//

import Foundation
import UIKit
import RealmSwift

class GetVCFromQRViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var documentTitleLabel: UILabel!
    @IBOutlet weak var didLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var documentLabel: UILabel!
    //    var documentMode: DocumentDetailMode?
    @IBOutlet weak var vcTableView: UITableView!
    @IBOutlet weak var vcTableViewHeightCon: NSLayoutConstraint!
    
    var listVCDoc : [VCDocument]?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        vcTableViewHeightCon.constant = vcTableView.contentSize.height
        
        let userDID = UserDefaults.standard.string(forKey: "DID_address")
        didLabel.text = userDID
        
        let datetime = Date().timeIntervalSince1970
        let strDate = Int64(datetime).toISOFormat()
        dateLabel.text = shortDateTime(dateStr: strDate)
        
        if(listVCDoc?.count ?? 0 > 0){
            let count = listVCDoc?.count ?? 0
            documentLabel.text = "ข้อมูลเอกสารที่ฉันได้รับ(\(count)/\(count)):"
            
            
        }

    }
    
    
//    func render(readlist : [String]){
//        let dbVC = realm.objects(VCDocument.self)
//        for vc in dbVC {
//            print("vc \(vc)")
//            for cid in readlist {
//                if(vc.cid == cid){
//                    listVCDoc.append(vc)
//                }
//            }
//        }
//    }
    
    @IBAction func touchBackToMainButton(_ sender: Any) {
        performSegue(withIdentifier: "goToMain", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listVCDoc!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! GetVCTableViewCell
        cell.nameLabel.text = "\(listVCDoc![indexPath.row].type)"
        cell.touchDetailButton = {
            self.performSegue(withIdentifier: "goToDetailVC", sender: self.listVCDoc![indexPath.row])
        }
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDetailVC"{
            let destination = segue.destination as? MyDocumentViewController
            let vc = sender as? VCDocument
            
            destination?.listVC = vc
            destination?.selectedRow = vc?.cid
        }
    }
    
}
