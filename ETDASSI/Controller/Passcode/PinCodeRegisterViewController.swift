//
//  PinCodeRegisterViewController.swift
//  ETDASSI
//
//  Created by Finema on 16/6/2564 BE.
//

import UIKit

class PinCodeRegisterViewController: UIViewController {
    
    @IBOutlet weak var passCodeBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passCodeBtn.layer.cornerRadius = 5
        passCodeBtn.setTitle("เริ่มต้นสร้างรหัสผ่าน", for: .normal)
        if UserManager.shared.isLogin {
            
            self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
            self.title = "ตั้งค่าความปลอดภัย"
            titleLabel.isHidden = true
            navigationItem.backButtonTitle = ""
            backButton.isHidden = true
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func touchBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
//    func goToNext(){
//        self.performSegue(withIdentifier: "goToPermissionRegister", sender: self)
//    }
}
