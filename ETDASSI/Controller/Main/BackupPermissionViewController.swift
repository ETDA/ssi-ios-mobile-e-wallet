//
//  BackupPermissionViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 19/7/2564 BE.
//

import Foundation
import UIKit
import LocalAuthentication


class BackupPermissionViewController: UIViewController {
    var callAPI : APIManager?
    override func viewDidLoad() {
        super.viewDidLoad()
        callAPI = APIManager()
    }
    
    @IBAction func touchDoneButton(_ sender: Any) {
        let context = LAContext()
        let myLocalizedReasonString = "Biometric Authentication !! "
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString){ success, evaluateError in
                DispatchQueue.main.async {
                    if(success){
                        self.callAPI?.mobileBackUpWallet(did: UserDefaults.standard.string(forKey: "DID_address") ?? "", context: context, onSuccess: { response in
                            UserDefaults.standard.set("Create_Wallet_Success", forKey: "Navigate_Flow")
                            self.goToNext()
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
    
    func goToNext(){
        self.performSegue(withIdentifier: "goToPinCodeRegister", sender: self)
    }
    
    @IBAction func touchBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
