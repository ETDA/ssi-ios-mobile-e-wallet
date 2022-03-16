//
//  BackupViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 14/7/2564 BE.
//

import Foundation
import UIKit

class BackupViewController: UIViewController {
    
//    var
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var backupButton: UIButton!
    
//    var isDisableBackup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        if UserManager.shared.isBackup {
            messageLabel.text = "คุณต้องการยกเลิกสำรองข้อมูลเอกสารรับรองภายใน ETDA e-Walletไว้กับผู้ให้บริการหรือไม่"
            backupButton.setTitle("ยกเลิกสำรองข้อมูล", for: .normal)
            backupButton.backgroundColor = UIColor(rgb: 0xFF4242)
        } 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func touchBackupButton(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "User", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GrantAccessViewController") as! GrantAccessViewController
        
        vc.verifyComplete = {
            UserManager.shared.isBackup = !UserManager.shared.isBackup
            self.navigationController?.popViewController(animated: true)
        }
        
        self.present(vc, animated: true, completion: nil)
    }
}
