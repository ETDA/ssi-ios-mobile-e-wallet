//
//  ChooseDocumentViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 28/6/2564 BE.
//

import Foundation
import UIKit
import RealmSwift

class ChooseDocumentViewController:UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var viewOtherDoc: UIView!
    @IBOutlet weak var tableViewSelect: UITableView!
    @IBOutlet weak var docTypeLabel: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    
    var selectedRow:Int?
    var dataVPReq : VpRequest?
    var dataVcDocument : VCDocument?
    var realmDB = try! Realm()
    var vcDoclist : [VCDocument]? = []
    weak var delegate: ReqDocDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        
        self.chooseButton.backgroundColor = UIColor(rgb: 0xD0D0D0)
        
        let vcDoc = realmDB.objects(VCDocument.self)
        let vcDocByCid = vcDoc.filter("type = %@", dataVPReq?.type)
        for vc in vcDocByCid{
            if vc.status == "active"{
                if dataVPReq != nil{
                    if dataVPReq!.isRequired{
                        vc.isReq = true
                    }
                }
                vcDoclist?.append(vc)
            }
        }
        
        if !vcDoclist!.isEmpty{
            vcDoclist!.reverse()
        }
        
        if((dataVPReq?.type.count)! > 18){
            docTypeLabel.textAlignment = .left
            docTypeLabel.text = dataVPReq?.type
        }else{
            docTypeLabel.text = dataVPReq?.type
        }
        
        searchTF.isHidden = true
        searchBtn.isHidden = true
        viewOtherDoc.isHidden = true
        
        docTypeLabel.numberOfLines =  0
//        tableViewSelect.isHidden = true
    }
    
    
    @IBAction func touchChooseButton(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToRequestDocument", sender: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToRequestDocument"{
            delegate?.selectlistVC(vcDoclist![selectedRow!])
        }
        
        if segue.identifier == "goToShowDocDetail" {
            let destination = segue.destination as? ChooseDocumentDetailViewController
            destination?.vcDocument = sender as? VCDocument
            destination?.delegate = delegate
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vcDoclist?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ChooseDocumentTableViewCell
        cell.nameLabel.text = vcDoclist![indexPath.row].type
        cell.dateLabel.text = shortDateTime(dateStr: vcDoclist![indexPath.row].issuanceDate)
        if let row = selectedRow, row == indexPath.row {
            cell.tickBoxImageView.image = UIImage(named: "tick_box_active")
        } else {
            cell.tickBoxImageView.image = UIImage(named: "tick_box_inactive")
        }
        
        cell.touchMagnifier = {
            self.performSegue(withIdentifier: "goToShowDocDetail", sender: self.vcDoclist![indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        tableView.reloadData()
        self.chooseButton.backgroundColor = UIColor(rgb: 0x0A214A)
        chooseButton.isEnabled = true
    }
    
}
