//
//  RegisterBackupViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 19/7/2564 BE.
//

import Foundation
import UIKit
import Presentr

class RegisterBackupViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func touchBackupButton(_ sender: Any) {
        UserManager.shared.isBackup = true
        UserDefaults.standard.set(true, forKey: "isBackup")
        goToNext(id: "goToAskPermission")
    }
    
    @IBAction func touchCancelButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainAlertWithMessageViewController") as! MainAlertWithMessageViewController
        vc.acceptButtonString = "สำรองข้อมูล"
        vc.cancelButtonString = "ไม่สำรอง"
        vc.titleString = "ไม่ต้องการสำรองข้อมูล ?"
        vc.messageString = "หากคุณไม่ได้สำรองข้อมูล เอกสารรับรองภายในETDA e-Wallet เมื่อข้อมูลสูญหายจะไม่สามารถกู้คืนข้อมูลกลับมาได้"
        vc.acceptButtonColor = 0x0A214A
        
        vc.touchAcceptButton = {
            
            UserManager.shared.isBackup = true
            UserDefaults.standard.set(true, forKey: "isBackup")
            
            
            self.dismiss(animated: true, completion: {
                self.goToNext(id: "goToAskPermission")
            })
            
//            self.dismiss(animated: true, completion: nil)
      
        }
        
        vc.touchCancelButton = {
            UserManager.shared.isBackup = false
            print("touchCancelButton");
            UserDefaults.standard.set(false, forKey: "isBackup")
            self.dismiss(animated: true, completion: {
                self.goToNext(id: "goToPinCodeRegister")
            })
       
        }
        
        let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: 335.0), height: ModalSize.custom(size: 195.0), center: ModalCenterPosition.center))
        presenter.roundCorners = true
        presenter.cornerRadius = 8.0
        customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)
    }
    
    func goToNext(id: String){
        self.performSegue(withIdentifier: id, sender: self)
    }
    
    @IBAction func touchBackButton(_ sender: Any) {

        self.dismiss(animated: true, completion: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    
}
