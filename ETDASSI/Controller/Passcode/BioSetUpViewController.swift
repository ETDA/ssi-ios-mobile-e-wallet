//
//  BioSetUpViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 15/7/2564 BE.
//

import Foundation
import UIKit
import Presentr
import LocalAuthentication

class BioSetUpViewController: UIViewController {
    
    var passcode = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func goToNext() {
        self.performSegue(withIdentifier: "goToFinishSetPasscode", sender: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFinishSetPasscode" {
            let vc = segue.destination as! FinishSetPasscodeViewController
            vc.passcode = passcode
        }
    }
    
    @IBAction func touchNextButton(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
//        self.goToNext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        
                        UserDefaults.standard.set("OPEN", forKey: "Biometric")
                        self.goToNext()
//                        self?.unlockSecretMessage()
                    } else {
                        // error
                    }
                }
            }
        } else {
            // no biometry
        }
        

//        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//            let reason = "Identify yourself!"
//
//            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
//                success, authenticationError in
//
//            }
    }
    
    @IBAction func touchSkipButton(_ sender: Any) {
        
        goToNext()

    }
    
    @IBAction func touchBackButton(_ sender: Any) {
        print("touchBackButton")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainAlertWithMessageViewController") as! MainAlertWithMessageViewController
        vc.acceptButtonString = "ยกเลิกรหัสผ่าน"
        vc.cancelButtonString = "ยกเลิก"
        vc.titleString = "ยกเลิกการตั้งรหัสผ่านล่าสุด ?"
        vc.messageString = "หากคุณยืนยันที่จะยกเลิกคุณจะต้องทำการตั้งรหัสผ่านใหม่อีก"
        vc.acceptButtonColor = 0xf44336
        vc.touchAcceptButton = {
            self.dismiss(animated: true, completion: {
                self.performSegue(withIdentifier: "gotoFirstSettingPasscodeScreen", sender: nil)
            })
        }
        vc.touchCancelButton = {
            self.dismiss(animated: true, completion: {
            })
        }
        
        let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: 335.0), height: ModalSize.custom(size: 196.0), center: ModalCenterPosition.center))
        presenter.roundCorners = true
        presenter.cornerRadius = 8.0
        customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)
    }
}
