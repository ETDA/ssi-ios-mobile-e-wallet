//
//  RestoreViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 20/7/2564 BE.
//

import Foundation
import UIKit
import Presentr

class RestoreViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func touchRestoreButton(_ sender: Any) {
        UserManager.shared.isBackup = true
        UserDefaults.standard.set(true, forKey: "isBackup")
        goToNext(id: "goToPermissionRegister")

    }
    
    @IBAction func touchSkipButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainAlertWithMessageViewController") as! MainAlertWithMessageViewController
        vc.acceptButtonString = "กู้คืนข้อมูล"
        vc.cancelButtonString = "ไม่กู้คืนข้อมูล"
        vc.titleString = "ไม่กู้คืนข้อมูล ?"
        vc.messageString = "หากคุณยืนยันที่จะไม่กู้คืน ข้อมูลที่สำรองไว้จะถูกลบทิ้งและระบบจะทำการสร้าง DID ใหม่ให้คุณคุณต้องการกู้คืนข้อมูลหรือไม่​ ?"
        vc.acceptButtonColor = 0x0A214A
        
        vc.touchAcceptButton = {
            self.dismiss(animated: true, completion: nil)
            UserManager.shared.isBackup = true
            UserDefaults.standard.set(true, forKey: "isBackup")
            self.goToNext(id: "goToPermissionRegister")
        }
        
        vc.touchCancelButton = {
            UserManager.shared.isBackup = false
            UserDefaults.standard.set(false, forKey: "isBackup")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.goToNext(id: "gotoRestartViewController")
            }
        }
        
        let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: 335.0), height: ModalSize.custom(size: 196.0), center: ModalCenterPosition.center))
        presenter.roundCorners = true
        presenter.cornerRadius = 8.0
        customPresentViewController(presenter, viewController: vc, animated: true, completion: nil)
        
    }
    
    func goToNext(id: String) {
        self.performSegue(withIdentifier: id, sender: nil)
        
    }
    
}
