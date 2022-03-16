//
//  AccountViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 17/6/2564 BE.
//

import Foundation
import UIKit
import LocalAuthentication

class AccountViewController: UIViewController {
    //var context : LAContext?
    @IBOutlet weak var backupSwitch: UISwitch!
    
    
    @IBOutlet weak var btnAccountView: UIButton!
    
    
    var user: User!
    var didLabel: String?
    var nameLabel: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "จัดการบัญชี"
        
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0x40C2D3), UIColor(rgb: 0x0A214A)], startPoint: .top, endPoint: .bottom)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        backupSwitch.isOn = UserManager.shared.isBackup
    }
    
    @IBAction func touchUserAccountButton(_ sender: Any) {
        
        btnAccountView.isEnabled = false
        
        let did = UserDefaults.standard.string(forKey: "DID_address")!

        if !did.isEmpty {

            APIManager.shared.mobileGetInfo(did: did) { data in
                self.user = User(data: data)

                if data != nil {
                
                   self.nameLabel = self.user.firstName + " " + self.user.lastName
                    self.didLabel = UserDefaults.standard.string(forKey: "DID_address")

                
                   UserProfileViewController.UserProfileVariable.nameString = self.nameLabel
                   UserProfileViewController.UserProfileVariable.didString = self.didLabel
                   UserProfileViewController.UserProfileVariable.userModel = self.user
               
                self.performSegue(withIdentifier: "goToUserAccount", sender: nil)
                    
                    self.btnAccountView.isEnabled = true
                }

            } onFailure: { error in
            self.navigationController?.popToRootViewController(animated: true)
            }

        }
        
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.performSegue(withIdentifier: "goToUserAccount", sender: nil)
//        }
        
       
    }
    
    @IBAction func touchChangePasscode(_ sender: Any) {
        performSegue(withIdentifier: "goToChangePasscode", sender: nil)
    }
    
    @IBAction func touchBackupSwitch(_ sender: Any) {
        performSegue(withIdentifier: "goToBackup", sender: nil)
    }
    
//    func canAuthenByBioMetrics() -> Bool {
//        let context = LAContext()
//        var authError: NSError?
//
//        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
//            return true
//        } else {
//            return false
//        }
//    }
//    func closeFaceID(){
//        if(context != nil){
//          print("_ctx_","ok..")
//        }else{
//            print("_ctx_","ok.2.")
//            
//            let contextA = LAContext()
//            
//        
//            let myLocalizedReasonString = "Biometric Authentication !! "
//            var error: NSError?
//            if contextA.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
//
//                contextA.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString){ success, evaluateError in
//                    DispatchQueue.main.async {
//                        if(success){
//                  
//                            print("_ctx_","ok..444")
//                           
//                        }
//                    }
//                }
//
//            } else {
//                // no biometry
//                print("_ctx_","no..")
//               
//
//            }
//        }
//        
//    }
    
    
}
