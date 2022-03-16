//
//  BioConfirmViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 15/7/2564 BE.
//

import Foundation
import UIKit
import LocalAuthentication
class BioConfirmViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var passcode = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserManager.shared.isLogin {
            
            self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
            self.title = "ตั้งค่าความปลอดภัย"
            titleLabel.isHidden = true
            navigationItem.backButtonTitle = ""

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFinishSetPasscode" {
            let vc = segue.destination as! FinishSetPasscodeViewController
            vc.passcode = passcode
        }
    }
    
    func goToNext() {
        self.performSegue(withIdentifier: "goToFinishSetPasscode", sender: nil)

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
      
    }
    
}
