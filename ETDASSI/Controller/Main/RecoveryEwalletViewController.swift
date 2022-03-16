//
//  RecoveryEwalletViewController.swift
//  ETDASSI
//
//  Created by peddev on 23/9/2564 BE.
//

import Foundation
import UIKit
import LocalAuthentication

class RecoveryEwalletViewController: UIViewController {
    
    @IBOutlet weak var imgLoading: UIImageView!
    @IBOutlet weak var lbStatus1: UILabel!
    @IBOutlet weak var lbStatus2: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    
    
    var callAPI : APIManager?
    var context : LAContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callAPI = APIManager()
        registerRecovery()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lbStatus1.text = "กรุณารอสักครู่ ระบบกำลังดำเนินการ"
        lbStatus2.text = "กู้คืนข้อมูล ETDA e-Wallet"
        rotateImage()

        
    }
    
    @IBAction func nextBtnTouch(_ sender: Any) {
        goToNext()
    }
    
    
    func rotateImage() {
        self.view.layoutIfNeeded()
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.imgLoading.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func registerRecovery(){
        if(context != nil){
            self.callAPI?.didRecovery(context: context!, onSuccess: { responseBool in
                                if(responseBool){
                                    self.getBackup(context: self.context!)
                                }else{
                                    self.errorPopup()
                                }
                            }, onFailure: { ErrorResponse in
                                self.errorPopup()
                            })
        }else{
            let contextA = LAContext()
            let myLocalizedReasonString = "Biometric Authentication !! "
            var error: NSError?
            if contextA.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {

                contextA.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString){ success, evaluateError in
                    DispatchQueue.main.async {
                        if(success){
                            self.callAPI?.didRecovery(context: contextA, onSuccess: { responseBool in
                                                if(responseBool){
                                                    self.getBackup(context: self.context!)
                                                }else{
                                                    self.errorPopup()
                                                }
                                            }, onFailure: { ErrorResponse in
                                                self.errorPopup()
                                            })
                        }
                    }
                }

            } else {
                // no biometry
                print("No Biometric")
                self.errorPopup()
            }
        }
        
    }
    
    func restoreSuccess(restore:RestoreVCResponse){
        
        lbStatus1.text = "เอกสารรับรองของคุณ สามารถกู้คืนได้ทั้งหมด \(restore.verifyHolderCount)/\(restore.holderCount)"
        lbStatus2.text = "เอกสารรับรองที่คุณลงนามรับรอง สามารถกู้คืนได้ทั้งหมด \(restore.verifyIssuerCount)/\(restore.issuerCount)"
        
        imgLoading.isHidden = true
        nextBtn.isHidden = false
        
    }
    
    func errorPopup(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterErrorViewController") as! RegisterErrorViewController
        self.present(vc, animated: true)
    }
    
    func getBackup(context :LAContext){
        self.callAPI?.restoreVC(context: context, onSuccess: { restoreRes in
            DispatchQueue.main.async {
                UserDefaults.standard.set("RESTORE_SUCCESS", forKey: "Navigate_Flow")
                self.restoreSuccess(restore: restoreRes)
            }
        }, onFailure: { (error) in
            self.errorPopup()
        })
    }
    
    func goToNext(){
        self.performSegue(withIdentifier: "goToStartEWalletRecovery", sender: nil)
    }
}
