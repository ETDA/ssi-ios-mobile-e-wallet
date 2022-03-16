//
//  RegisterErrorViewController.swift
//  ETDASSI
//
//  Created by Finema on 1/9/2564 BE.
//

import Foundation
import UIKit
class RegisterErrorViewController: UIViewController {
    @IBOutlet weak var againBtn: UIButton!
    var userFlow: String = ""
    override func viewDidLoad() {
        userFlow = UserDefaults.standard.string(forKey: "Navigate_Flow") ?? ""
    }
    
    @IBAction func touchAgainBtn(_ sender: Any) {
        switch userFlow {
        case "REGISTER_VERIFY_SUCCESS":
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
            self.present(vc, animated: true)
        case "RECOVERY_CHECK":
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RecoveryEwalletViewController") as! RecoveryEwalletViewController
            self.present(vc, animated: true)
        default:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RegisterDopaViewController") as! RegisterDopaViewController
            
            self.present(vc, animated: true)
        }
        
        
//        if(userFlow == "REGISTER_VERIFY_SUCCESS"){
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
//            self.present(vc, animated: true)
//        }else{
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "RegisterDopaViewController") as! RegisterDopaViewController
//            
//            self.present(vc, animated: true)
//        }
    }
    
}
