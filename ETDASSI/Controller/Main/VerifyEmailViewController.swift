//
//  VerifyEmailViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 19/7/2564 BE.
//

import Foundation
import UIKit

class VerifyEmailViewController: UIViewController {
    
    var email: String?
    
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let email = email {
            emailLabel.text = email
        }
    }
    
    func goToNext() {
        self.performSegue(withIdentifier: "goToCheckDopa", sender: self)
        
    }
    
    @IBAction func touchSendAgainButton(_ sender: Any) {
        self.goToNext()
    }
    
    @IBAction func touchBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
