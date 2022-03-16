//
//  ChooseDocumentDetailViewController.swift
//  ETDASSI
//
//  Created by Finema on 6/10/2564 BE.
//

import Foundation
import UIKit
import Presentr
import SwiftyJSON

class ChooseDocumentDetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    @IBOutlet weak var contrainerView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var contrainerViewHeightCon: NSLayoutConstraint!
    @IBOutlet weak var chooseButton: UIButton!
    
    
    var vcDocument : VCDocument!
    weak var delegate: ReqDocDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(vcDocument != nil){
            typeLabel.text = vcDocument.type
        }
        
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chooseDocumentDetail" {
            let vc = segue.destination as! DocumentDetailViewController
            print("ContainerViewHeightCon")
            if(vcDocument != nil){
                vc.payload = JWTManager.shared.getCredentialSchemaFromJWT(jwt: vcDocument.jwt)
                vc.updateTableViewHeight = { height in
                    self.contrainerViewHeightCon.constant = height
                }
            }else{
                vc.payload = JWTManager.shared.getHeaderFromJWT(jwt: JWTManager().testJWT)
                vc.updateTableViewHeight = { height in
                    self.contrainerViewHeightCon.constant = height
                }
            }
        }
        
        if segue.identifier == "unwindToRequestDocument"{
            delegate?.selectlistVC(vcDocument)
        }
    }
    
    @IBAction func touchChooseButton(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToRequestDocument", sender: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MyDocumentTableViewCell
        cell.titleLabel.text = "test"
        cell.detailLabel.text = "TEST"
        return cell
    }
    

}
