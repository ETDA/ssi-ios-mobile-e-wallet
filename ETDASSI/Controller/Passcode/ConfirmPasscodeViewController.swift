//
//  ConfirmPasscodeViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 16/6/2564 BE.
//

import Foundation
import UIKit
import Presentr

class ComfirmPasscodeViewController: UIViewController {
    
    @IBOutlet weak var passcodeView: PasscodeView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    var oldPasscode = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passcodeView.touchFullPassCode = { passcode in
            if UserManager.shared.isLogin {
                self.goToNext(passcode)
            } else {
                if self.oldPasscode == passcode {
                    print("sameCode")
                    self.goToNext(passcode)
                } else {
                    print("notSameCode")
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
            passcodeView.titleLabel.text = "กรอกรหัสผ่านใหม่"
        }
        passcodeView.hideBioMetricButton()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        passcodeView.reset()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToBioConfirm" {
            let vc = segue.destination as! BioConfirmViewController
            let passcode = sender as! [String]
            vc.passcode = passcode
        } else if segue.identifier == "goToBioSetup" {
            let vc = segue.destination as! BioSetUpViewController
            let passcode = sender as! [String]
            vc.passcode = passcode
        }
    }
    
    func goToNext(_ passcode: [String]) {
        if UserManager.shared.isLogin {
            self.performSegue(withIdentifier: "goToBioConfirm", sender: passcode)
        } else {
            self.performSegue(withIdentifier: "goToBioSetup", sender: passcode)

        }
    }
    @IBAction func touchBackButton(_ sender: Any) {
        performSegue(withIdentifier: "gotoFirstSettingPasscodeScreen", sender: nil)
       // self.navigationController?.popViewController(animated: true)
    }
}
