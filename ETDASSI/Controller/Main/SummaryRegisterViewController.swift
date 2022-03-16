//
//  SummaryRegisterViewController.swift
//  ETDASSI
//
//  Created by Finema on 16/6/2564 BE.
//

import UIKit
import Presentr
import LocalAuthentication
import Foundation

class SummaryRegisterViewController: UIViewController {
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var didLabel: UILabel!
    
    var callAPI : APIManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextBtn.layer.cornerRadius = 5
        nextBtn.setTitle("ดำเนินการต่อ", for: .normal)
        if UserManager.shared.isBackup {
            print("_recovery_","start..")
            titleLabel.text = "กู้คืนข้อมูล\nETDA e-Wallet สำเร็จ"
        }
        
       
        callAPI = APIManager()
        
        didLabel.text = self.subAsDidAddress()
    }
    
    func forceBackupAfterRecovery(){
        let context = LAContext()
        let myLocalizedReasonString = "Biometric Authentication !! "
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString){ success, evaluateError in
                DispatchQueue.main.async {
                    if(success){
                        self.callAPI?.mobileBackUpWallet(did: UserDefaults.standard.string(forKey: "DID_address") ?? "", context: context, onSuccess: { response in
                            UserDefaults.standard.set("Create_Wallet_Success", forKey: "Navigate_Flow")
                         
                        }, onFailure: { error in
                            // Show some Dialog
                            print(error)
                        })
                       
                    }
                }
            }
            
        } else {
            // no biometry
        }
        
    }
    
    func subAsDidAddress() -> String{
        let did = UserDefaults.standard.string(forKey: "DID_address") ?? ""
        if did == "" {
            return ""
        }else{
            print(did)
            let index = did.index(did.startIndex, offsetBy: 12)
            let index1 = did.index(did.endIndex, offsetBy: -4)
            let substring = did[..<index]
            let substring1 = did[index1...]
            let subDid = "\(substring)xxxxxxxxxxxxx\(substring1)"
            return subDid
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    @IBAction func nextBtnTapped(_ sender: Any) {
        print("_recovery_","status \(UserManager.shared.isBackup)")
        
        //PinCodeRegisterViewController
        //PinCodeRegisterViewController
        if UserManager.shared.isBackup {
            print("_recovery_","yes..")
            
            UserManager.shared.isBackup = true
            UserDefaults.standard.set(true, forKey: "isBackup")
            forceBackupAfterRecovery()
            goToNext(id: "goToPinCodeRegister")
        } else {
            print("_recovery_","no..")
            goToNext(id: "goToBackup")
        }
    }
    
    @IBAction func touchDIDButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        vc.messageString = "เลขประจำตัว(DID) เป็นเลขที่ใช้ในการระบุตัวตนของแต่ละบุคคล เพื่อใช้ในการเข้าถึงธุรกรรมหรือบริการต่างๆได้ด้วยตนเอง"
        vc.titleString = "DID (Decentralized identifier)"
        
        let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: 335.0), height: ModalSize.custom(size: 149.0), center: .bottomCenter))
        presenter.roundCorners = true
        presenter.cornerRadius = 8.0
        customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)
    }
    
    func goToNext(id: String){
        self.performSegue(withIdentifier: id, sender: self)
    }
}








