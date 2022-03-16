//
//  UserLoginViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 28/6/2564 BE.
//

import Foundation
import UIKit
import Presentr
import LocalAuthentication

class UserLoginViewController: UIViewController {
    
    @IBOutlet weak var passCodeView: PasscodeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        passCodeView.titleLabel.text = "กรุณาใส่รหัสผ่าน"
        passCodeView.biomaticFinish = { [weak self] in
            self?.goToNext() ;
        }
        passCodeView.touchFullPassCode = { passcode in
            print(UserDefaults.standard.array(forKey: "passCode"))
            if passcode == UserDefaults.standard.array(forKey: "passCode") as! [String] {
                self.goToNext()
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let infoVC = storyboard.instantiateViewController(withIdentifier: "MainAlertInfoViewController") as! MainAlertInfoViewController
                
                infoVC.titleString = "รหัสผิดพลาด"
                infoVC.messageString = "กรุณากรอกใหม่อีกครั้ง"
                
                let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: Float(UIScreen.main.bounds.width) - 40), height: ModalSize.custom(size: 91.0), center: ModalCenterPosition.center))
                presenter.roundCorners = true
                presenter.cornerRadius = 8.0
                self.customPresentViewController(presenter, viewController: infoVC, animated: true, completion: nil)
                self.passCodeView.reset()
            }
        }
        
        let biometric = UserDefaults.standard.string(forKey: "Biometric")
       
            if(biometric != nil){
                let context = LAContext()
                var error: NSError?
                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                    let reason = "Identify yourself!"

                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                        success, authenticationError in

                        DispatchQueue.main.async {
                            if success {
                                self.goToNext()

                            } else {
                                // error
                            }
                        }
                    }
                } else {
                    // no biometry
                }
            }
        
    }
    
    func goToNext(){
        self.performSegue(withIdentifier: "goToMainTabbar", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.passCodeView.reset()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
