//
//  SetDeviceViewController.swift
//  ETDASSI
//
//  Created by Mee on 17/11/2564 BE.
//

import UIKit
import LocalAuthentication

class SetDeviceViewController: UIViewController {

    enum BiometricType{
        case touch
        case face
        case none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        getBiometricType()
//        DispatchQueue.main.async {
//            self.supportedBiometricType()
//        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
    
    func getBiometricType() {
        
        let context = LAContext()

        var error: NSError?

        if context.canEvaluatePolicy(
            LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                error: &error) {
            print("Biometry is available on the device")
            // Biometry is available on the device
        } else {
            print("Biometry is not available on the device")
            // Biometry is not available on the device
            // No hardware support or user has not set up biometric auth
        }

    }
    
    private func supportedBiometricType ()
    {
        
        let userFlow = UserDefaults.standard.string(forKey: "Navigate_Flow")
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        {
            print("no deviceOwnerAuthenticationWithBiometrics")

        } else {
            print("deviceOwnerAuthenticationWithBiometrics")
        }
       
//      self.navigationController?.popToRootViewController(animated: true)


    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func TouchidBtnTouch(_ sender: Any) {
   
//
        if let url = URL(string: "App-Prefs:root=ACCESSIBILITY&path=FACE_ID") {
            UIApplication.shared.openURL(url)
        }
    }
    
}
