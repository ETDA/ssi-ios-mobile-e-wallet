//
//  TermAndConditionViewController.swift
//  ETDASSI
//
//  Created by Finema on 14/6/2564 BE.
//

import UIKit
import KRProgressHUD
import KRActivityIndicatorView
import CryptoKit
import SwiftyJSON


class TermAndConditionViewController: UIViewController{
    
    @IBOutlet weak var acceptsBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        acceptsBtn.layer.cornerRadius = 5
        acceptsBtn.setTitle("ยอมรับ", for: .normal)
        
    
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.topItem?.title = " " 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func acceptBtn(_ sender: Any) {
        goToNext()
    }
    
    func goToNext(){
        self.performSegue(withIdentifier: "goToRegisterDopa", sender: self)
    }
    
    @IBAction func touchCheckBox(_ sender: UIButton) {
        
            if sender.isSelected {
                acceptsBtn.isEnabled = false
                sender.isSelected = false
                acceptsBtn.backgroundColor = UIColor(rgb: 0xD0D0D0)
            } else {
                acceptsBtn.isEnabled = true
                sender.isSelected = true
                acceptsBtn.backgroundColor = UIColor(rgb: 0x0A214A)
            }
    }
    
    
}
