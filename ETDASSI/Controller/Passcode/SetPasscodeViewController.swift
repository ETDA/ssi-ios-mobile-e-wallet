//
//  SetPasscodeViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 16/6/2564 BE.
//

import Foundation
import UIKit
import Presentr

class SetPasscodeViewController: UIViewController {
    
    @IBOutlet weak var passcodeView: PasscodeView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passcodeView.touchFullPassCode = { passcode in
            if UserManager.shared.isLogin {
                if passcode == UserDefaults.standard.array(forKey: "passCode") as! [String] {
                    self.goToNext(passcode)
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let infoVC = storyboard.instantiateViewController(withIdentifier: "MainAlertInfoViewController") as! MainAlertInfoViewController
                    
                    infoVC.titleString = "รหัสผิดพลาด"
                    infoVC.messageString = "กรุณากรอกใหม่อีกครั้ง"
                    
                    let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: Float(UIScreen.main.bounds.width) - 40), height: ModalSize.custom(size: 91.0), center: ModalCenterPosition.center))
                    presenter.roundCorners = true
                    presenter.cornerRadius = 8.0
                    self.customPresentViewController(presenter, viewController: infoVC, animated: true, completion: nil)
                    self.passcodeView.reset()
                }
            } else {
                self.goToNext(passcode)
            }
        }
        if UserManager.shared.isLogin {
            
            self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
            self.title = "ตั้งค่าความปลอดภัย"
            titleLabel.isHidden = true
            navigationItem.backButtonTitle = ""
            backButton.isHidden = true
            passcodeView.titleLabel.text = "กรอกรหัสผ่านเดิม"

        }
        passcodeView.hideBioMetricButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        passcodeView.reset()
        
    }
    
    func goToNext(_ passcode: [String]){
        self.performSegue(withIdentifier: "goToComfirmPasscode", sender: passcode)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToComfirmPasscode" {
            let vc = segue.destination as! ComfirmPasscodeViewController
            vc.oldPasscode = sender as! [String]
        }
    }
    
    @IBAction func touchBackButton(_ sender: Any) {
        performSegue(withIdentifier: "gotoFirstSettingPasscodeScreen1", sender: nil)
//       self.navigationController?.popViewController(animated: true)
    }
}
