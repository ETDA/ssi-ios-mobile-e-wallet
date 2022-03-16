//
//  FinishSetPasscodeViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 1/7/2564 BE.
//

import Foundation
import UIKit

class FinishSetPasscodeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var passcode = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        self.title = "ตั้งค่าความปลอดภัย"
        titleLabel.isHidden = true
        navigationItem.backButtonTitle = ""
        UserDefaults.standard.setValue(passcode, forKey: "passCode")
        UserDefaults.standard.set("FINISH_SETPASS_FLOW", forKey: "Navigate_Flow")
        print(UserDefaults.standard.array(forKey: "passCode"))
    }
    
    @IBAction func touchDoneButton(_ sender: Any) {
//        self.parent?.dismiss(animated: true, completion: {
//            
//        })
        
        let FromRegister = UserDefaults.standard.bool(forKey: "FirstRegister")
        if(!FromRegister){
            if UserManager.shared.isLogin {
                self.parent?.dismiss(animated: true, completion: nil)
                print("FinishSetPasscode UserManager login")
    //            self.navigationController?.popToRootViewController(animated: true)
            } else {
                print("Register UserManager login")
                self.performSegue(withIdentifier: "goToUserStoryboard", sender: nil)
            }
        } else {
            print("Register UserManager login")
            UserDefaults.standard.set(false, forKey: "FirstRegister")
            self.performSegue(withIdentifier: "goToUserStoryboard", sender: nil)
        }
        
       
        
        
        
        UserManager.shared.isLogin = true
    }
}
