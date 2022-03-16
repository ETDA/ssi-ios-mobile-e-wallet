//
//  GrantAccessViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 14/7/2564 BE.
//

import Foundation
import UIKit
import Presentr
import LocalAuthentication

class GrantAccessViewController: UIViewController {
    
    var verifyComplete: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func touchCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchDoneButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "FaceIDViewController") as! FaceIDViewController
//        
//        
//        let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: 261.0), height: ModalSize.custom(size: 192.0), center: ModalCenterPosition.center))
//        presenter.roundCorners = true
//        presenter.cornerRadius = 8.0
//        customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)
        let context = LAContext()
        var error: NSError?
//        self.goToNext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                success, authenticationError in

                DispatchQueue.main.async {
                    if success {

                        
                        self.verifyComplete?()
                        self.dismiss(animated: true, completion: nil)
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
}
