//
//  SignedDocumentViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 30/8/2564 BE.
// 

import Foundation
import UIKit
import Presentr
import SwiftyJSON

class SignedDocumentViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var containerViewHeightCon: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var revokeBtn: UIButton!
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet weak var lblDocumentName: UILabel!
    
    @IBOutlet weak var lblSignedDate: UILabel!
    
    var documentName: String? = ""
    var documentCreatedDate: String? = ""
    
    var callAPI : APIManager?
    
    var notificationDocument: SignedDocument!
    var jwtJSON : JSON? = nil
    
    @IBOutlet weak var viewMain: UIView!
    
    @IBOutlet weak var documentNameTopConstrain: NSLayoutConstraint!
    @IBOutlet weak var viewMainHeightConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var viewDivider: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callAPI = APIManager()
        if(notificationDocument != nil){
            jwtJSON = JWTManager.shared.getCredentialSchemaFromJWT(jwt: self.notificationDocument.jwt)
            if(notificationDocument.signingStatus == "REVOKED"){
                lineView.isHidden = true
                revokeBtn.isHidden = true
                
                viewDivider.isHidden = true
                viewMainHeightConstrain.constant = 120.0
                documentNameTopConstrain.constant = 25.0
            }else{
                viewMainHeightConstrain.constant = 157.5
                documentNameTopConstrain.constant = 15.0
            }
        }
        
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0xFBB617), UIColor(rgb: 0xFB9317)], startPoint: .top, endPoint: .bottom)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        
        
        lblDocumentName.text = documentName
        lblSignedDate.text = documentCreatedDate
        
        
        
        
        
        self.view.layoutIfNeeded()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "documentDetailSign" {
            let vc = segue.destination as! DocumentDetailViewController
            print("ContainerViewHeightCon")
            if(notificationDocument != nil){
                vc.payload = JWTManager.shared.getHeaderFromJWT(jwt: notificationDocument.message)
                vc.updateTableViewHeight = { height in
                    self.containerViewHeightCon.constant = height
                }
            }else{
                vc.payload = JWTManager.shared.getHeaderFromJWT(jwt: JWTManager().testJWT)
                vc.updateTableViewHeight = { height in
                    self.containerViewHeightCon.constant = height
                }
            }
        }
    }
    
    @IBAction func touchRevokeButton(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainAlertWithMessageViewController") as! MainAlertWithMessageViewController
        vc.acceptButtonString = "เพิกถอน"
        vc.cancelButtonString = "ยกเลิก"
        vc.titleString = "เพิกถอนเอกสารนี้?"
        vc.messageString = "หากคุณทำการเพิกถอน เอกสารนี้จะไม่สามารถนำกลับมาใช้งานได้อีก"
        vc.acceptButtonColor = 0x0A214A
        vc.touchAcceptButton = {
            let cid = self.jwtJSON!["jti"].stringValue
            self.callAPI?.revokeVC(notificationDocumentID: self.notificationDocument.id, cid: cid, onSuccess: { responseJSON in
                print("Revoke Success : \(responseJSON)")
                self.popup()
            }, onFailure: { errorRevoke in
                print("error Revoke \(errorRevoke.message)")
            })
            self.dismiss(animated: true, completion: nil)
        }
        
        vc.touchCancelButton = {
            self.dismiss(animated: true, completion: nil)
        }
        
        let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: 335.0), height: ModalSize.custom(size: 191.0), center: ModalCenterPosition.center))
        presenter.roundCorners = true
        presenter.cornerRadius = 8.0
        customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)
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
    
    func popup(){
        revokeBtn.isHidden = true
        lineView.isHidden = true
        let storyboards = UIStoryboard(name: "Main", bundle: nil)
            let infoVC = storyboards.instantiateViewController(withIdentifier: "MainAlertInfoViewController") as! MainAlertInfoViewController
            
            infoVC.titleString = "การเพิกถอนเอกสารเสร็จสิ้น"
            infoVC.messageString = "เอกสารดังกล่าวไม่สามารถนำกลับมาใช้งานได้"
            
            let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: 335.0), height: ModalSize.custom(size: 91.0), center: ModalCenterPosition.center))
            presenter.roundCorners = true
            presenter.cornerRadius = 8.0
            self.customPresentViewController(presenter, viewController: infoVC, animated: true, completion: nil)
        
        
        if(notificationDocument != nil){
            jwtJSON = JWTManager.shared.getCredentialSchemaFromJWT(jwt: self.notificationDocument.jwt)
            if(notificationDocument.signingStatus == "REVOKED"){
                lineView.isHidden = true
                revokeBtn.isHidden = true
                
                viewDivider.isHidden = true
                viewMainHeightConstrain.constant = 120.0
                documentNameTopConstrain.constant = 25.0
            }else{
                viewMainHeightConstrain.constant = 157.5
                documentNameTopConstrain.constant = 15.0
            }
        }
        
        
    }
}
