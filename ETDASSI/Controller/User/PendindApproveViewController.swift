//
//  PendindApproveViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 18/6/2564 BE.
//

import Foundation
import UIKit
import Presentr
import LocalAuthentication
import KRProgressHUD

class PendingApproveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeightCon: NSLayoutConstraint!
    
    @IBOutlet weak var didLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel! //document name
    
    @IBOutlet weak var lblOrganizationName: UILabel!
    
    // TODO: make subclass
    var notificationDocument: NotificationDocument!
    var credentialVCDetail : CredentialVCDetail?
    
    @IBOutlet weak var btnStatus: UIButton!
    @IBOutlet weak var denyBtn: UIButton!
    @IBOutlet weak var signBtn: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingImage: UIImageView!
    
    var listVPDoc : [VPDocumentDB] = []
    var vpOrganizationName : String?
    
    
    var myContext: LAContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0xFBB617), UIColor(rgb: 0xFB9317)], startPoint: .top, endPoint: .bottom)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        
        self.loadingView.isHidden = true
        
        
        let vpDocs = VPDocumentDB.get()
        for item in vpDocs {
            listVPDoc.append(item)
           
        }
        
        
        if(notificationDocument != nil){
            let jwtMessage = JWTManager.shared.getHeaderFromJWT(jwt: notificationDocument.message)
            
            print("_vc_2_",jwtMessage.rawValue)
            
         
            let vcMessage = jwtMessage["vc"]
            
            print("_vc_",vcMessage.rawValue)
            
            let decoder = JSONDecoder()
            credentialVCDetail = try! decoder.decode(CredentialVCDetail.self, from:vcMessage.rawData())
            
     
            lblOrganizationName.text = notificationDocument.creator
            
            didLabel.text =  UserDefaults.standard.string(forKey: "DID_address")
            didLabel.numberOfLines = 0
            
            typeLabel.text = credentialVCDetail?.type[1]
        }
        
        
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rotateImage()
    }
    
    func rotateImage() {
        self.view.layoutIfNeeded()
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.loadingImage.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    @IBAction func tapDenyButton(_ sender: Any) {
        self.disableSignBtn(button: self.signBtn)
        self.disableDenyBtn(button: self.denyBtn)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainAlertWithTextViewViewController") as! MainAlertWithTextViewViewController
        
        vc.touchCancelButton = {
            self.enableSignBtn(button: self.signBtn)
            self.enableDenyBtn(button: self.denyBtn)
            vc.dismiss(animated: true, completion: nil)

        }
        
        
        
        vc.touchAcceptButton = {
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                APIManager.shared.rejectVC(
                    document: self.notificationDocument,
                    reason: vc.reasonTextView.text
                ) {
                    vc.dismiss(animated: true, completion: {
                        let infoVC = storyboard.instantiateViewController(withIdentifier: "MainAlertInfoViewController") as! MainAlertInfoViewController
                        
                        infoVC.titleString = "ปฏิเสธการลงนามเอกสารนี้"
                        infoVC.messageString = "เอกสารดังกล่าวได้ถูกส่งกลับไปยังผู้ร้องขอ"
                        
                    
                        
                        let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: Float(UIScreen.main.bounds.width) - 40), height: ModalSize.custom(size: 91.0), center: ModalCenterPosition.center))
                        presenter.roundCorners = true
                        presenter.cornerRadius = 8.0
                        
                        self.customPresentViewController(presenter, viewController: infoVC, animated: true, completion: {
                            
                        
                       
                            self.dismiss(animated: true, completion: {
               
                                let storyboardUser = UIStoryboard(name: "User", bundle: nil)
                                let vcBack = storyboardUser.instantiateViewController(withIdentifier: "MainTabbarController") as! MainTabbarController
                                
                    
                           
                                self.performSegue (withIdentifier: "gotoMainAfterReject", sender: self)
                            })
                        })
                        
//
                    
                    })
                } onFailure: { errorResponse in
                    // TODO: handle error
                    self.enableSignBtn(button: self.signBtn)
                    self.enableDenyBtn(button: self.denyBtn)
                    KRProgressHUD.showError(withMessage: errorResponse.message)
                }
            } else {
                // no biometry
                self.enableSignBtn(button: self.signBtn)
                self.enableDenyBtn(button: self.denyBtn)
                KRProgressHUD.showError(withMessage: "No biometric")
            }
        }
        
        
        let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: Float(UIScreen.main.bounds.width) - 40), height: ModalSize.custom(size: 231.0), center: ModalCenterPosition.center))
        presenter.roundCorners = true
        presenter.cornerRadius = 8.0
        presenter.viewControllerForContext = self
            customPresentViewController(presenter, viewController: vc, animated: true, completion: {
                self.enableSignBtn(button: self.signBtn)
                self.enableDenyBtn(button: self.denyBtn)
            })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToComplete" {
            let destinationVC = segue.destination as! CompleteViewController
            destinationVC.mode = .normal
            destinationVC.notificationDocument = notificationDocument
            destinationVC.header = "การลงนามเอกสารรับรองเสร็จสมบูรณ์"
            destinationVC.detailHeader = "ระบบดำเนินการลงลายมือชื่อดิจิทัล"
//            destinationVC.documentMode = .detail
        } else if segue.identifier == "documentDetail" {
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
    
    
    @IBAction func touchSignButton(_ sender: Any) {
        self.disableSignBtn(button: self.signBtn)
        self.disableDenyBtn(button: self.denyBtn)
        let context = LAContext()
        let myLocalizedReasonString = "Biometric Authentication !! "
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString){ success, evaluateError in
                DispatchQueue.main.async {
                    if(success){
                        APIManager.shared.approveVC(
                            document: self.notificationDocument,context: context) {
                                self.performSegue(withIdentifier: "goToComplete", sender: nil)
                            } onFailure: { errorResponse in
                                self.enableSignBtn(button: self.signBtn)
                                self.enableDenyBtn(button: self.denyBtn)
                                KRProgressHUD.showError(withMessage: errorResponse.message)
                            }
                    }
                }
            }
            
        } else {
            // no biometry
            self.enableSignBtn(button: self.signBtn)
            self.enableDenyBtn(button: self.denyBtn)
            
            KRProgressHUD.showError(withMessage: "No biometric")
        }
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
    
    
    func enableSignBtn(button: UIButton){
        self.loadingView.isHidden = true
        button.isEnabled = true
//        button.backgroundColor = UIColor(red: 10, green: 33, blue: 74, alpha: 1.0)
//        button.tintColor = UIColor(red: 10, green: 33, blue: 74, alpha: 1.0)
//        button.setTitleColor(UIColor.white, for: .normal)
    }
    
    func enableDenyBtn(button: UIButton){
        self.loadingView.isHidden = true
        button.isEnabled = true
//        button.backgroundColor = UIColor.white
//        button.tintColor = UIColor.white
//        button.setTitleColor(UIColor(red: 10, green: 33, blue: 74, alpha: 1.0), for: .normal)
    }
    
    
    func disableSignBtn(button: UIButton){
        self.loadingView.isHidden = false
        button.isEnabled = false
//        button.backgroundColor = UIColor(red: 6, green: 6, blue: 6, alpha: 0.1)
//        button.tintColor = UIColor(red: 6, green: 6, blue: 6, alpha: 0.1)
//        button.setTitleColor(UIColor.white, for: .normal)
    }
    
    func disableDenyBtn(button: UIButton){
        self.loadingView.isHidden = false
        button.isEnabled = false
//        button.backgroundColor = UIColor.white
//        button.tintColor = UIColor.white
//        button.setTitleColor(UIColor(red: 6, green: 6, blue: 6, alpha: 0.1), for: .normal)
    }
    
}
