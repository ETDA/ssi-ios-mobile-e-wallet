//
//  CompleteVPViewController.swift
//  ETDASSI
//
//  Created by Finema on 13/10/2564 BE.
//

import Foundation
import UIKit
import RealmSwift

class CompleteVPViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var didLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var organizationLabel: UILabel!
    @IBOutlet weak var nameDocLabel: UILabel!
    @IBOutlet weak var vcTBView: UITableView!
    @IBOutlet weak var vcTableViewHeightCon: NSLayoutConstraint!
    
    var vpDoc : VPDocument?
    var listVCDoc : [VCDocument]?
    
    var realmDB = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        vcTableViewHeightCon.constant = vcTBView.contentSize.height
        
        if(vpDoc != nil){
            didLabel.text = vpDoc?.verifierDid
            organizationLabel.text = vpDoc?.verifier
            nameDocLabel.text = vpDoc?.name

            let vpDocDB = realmDB.objects(VPDocumentDB.self)
            let vpDocByName = vpDocDB.filter("name = %@",vpDoc?.name)
            
            let vp = vpDocByName.last
            
            if vp != nil {
                dateLabel.text = shortDateTime(dateStr: vp!.sendAt) 
            }
        }
    }
    
    @IBAction func touchBackBtn(_ sender: Any) {
        performSegue(withIdentifier: "vpGoToMain", sender: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! VPTableViewController
        let countList =  indexPath.row + 1
        cell.nameLabel.text = "\(countList).\(listVCDoc![indexPath.row].type)"
        
        return cell
    }
    
    
    
}
