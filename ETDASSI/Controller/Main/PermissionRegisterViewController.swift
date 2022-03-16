//
//  PermissionRegisterViewController.swift
//  ETDASSI
//
//  Created by Finema on 14/6/2564 BE.
//

import UIKit
import KRProgressHUD
import KRActivityIndicatorView
import CryptoKit
import SwiftyJSON
import Presentr
import LocalAuthentication

class PermissionRegisterViewController: UIViewController {
    @IBOutlet weak var nextBtn: UIButton!
    var context: LAContext?
    var callAPI : APIManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callAPI = APIManager()
        nextBtn.layer.cornerRadius = 5
        nextBtn.setTitle("ยืนยัน", for: .normal)
        UserDefaults.standard.set(false, forKey: "FirstRegister")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func verifyBtnTapped(_ sender: Any) {
        context = LAContext()
        var error: NSError?
        
        if context!.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            context!.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        let userFlow = UserDefaults.standard.string(forKey: "Navigate_Flow")
                        if(userFlow == "RECOVERY_CHECK"){
                            UserDefaults.standard.set(true, forKey: "FirstRegister")
                            self.goToLoadingRecoveryEWallet()
                        }else{
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            UserDefaults.standard.set("REGISTER_SUCCESS", forKey: "Navigate_Flow")
                            let vc = storyboard.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
                            vc.context = self.context ;
                            self.present(vc, animated: true);
                        }
//                        self?.unlockSecretMessage()
                    } else {
                        // error
                    }
                }
            }
        } else {
            // no biometry
        }
    }
    
//
//    @IBAction func verifyBtnTapped(_ sender: Any) {
//        context = LAContext()
//        var error: NSError?
////        self.goToNext()
//
//        if context!.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//            let reason = "Identify yourself!"
//
//            context!.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
//                success, authenticationError in
//
//                DispatchQueue.main.async {
//                    if success {
//                        let userFlow = UserDefaults.standard.string(forKey: "Navigate_Flow")
//                        if(userFlow == "RECOVERY_CHECK"){
//                            self.goToLoadingRecoveryEWallet()
//
//                        }else{
//                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                            let vc = storyboard.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
//
//                            self.present(vc, animated: true) {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                    self.dismiss(animated: true) {
//                                        UserDefaults.standard.set("REGISTER_SUCCESS", forKey: "Navigate_Flow")
//                                        self.goToNext()
//                                    }
//                                }
//                            }
//                        }
//
//
////                        self?.unlockSecretMessage()
//                    } else {
//                        // error
//                    }
//                }
//            }
//        } else {
//            // no biometry
//        }
//    }
    
    func goToLoadingRecoveryEWallet(){
        self.performSegue(withIdentifier: "goToLoadingRecoveryEWallet", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToLoadingRecoveryEWallet"){
            let destination = segue.destination as? RecoveryEwalletViewController
            destination?.context = context
        }
    }
    
    func goToNext(){
        self.performSegue(withIdentifier: "goToStartEWallet", sender: self)
    }
    
    @IBAction func touchPrivateKeyInfoButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        vc.messageString = "เป็นกุญแจที่ใช้รักษาข้อมูลส่วนตัวของแต่ละบุคคลเพื่อไม่ให้บุคคลอื่นสามารถเข้าถึงข้อมูลนั้นได้"
        vc.titleString = "Private Key หรือกุญแจลับส่วนตัว"
        
        let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: 335.0), height: ModalSize.custom(size: 131.0), center: .bottomCenter))
        presenter.roundCorners = true
        presenter.cornerRadius = 8.0
        customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)
    }
    
    @IBAction func touchBackButton(_ sender: Any) {
        
        performSegue(withIdentifier: "gotoRegisterSuccessPage", sender: nil)
//        self.navigationController?.popViewController(animated: true)
    }
    
}
