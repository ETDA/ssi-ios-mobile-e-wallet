//
//  SecureBiometricViewController.swift
//  ETDASSI
//
//  Created by Finema on 16/6/2564 BE.
//

import UIKit

class SecureBiometricViewController: UIViewController{
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startBtn.layer.cornerRadius = 5
        startBtn.setTitle("เปิดใช้งาน", for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func startBtnTapped(_ sender: Any) {
        
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
        goToNext()
    }
    
    func goToNext(){
        self.performSegue(withIdentifier: "goToSummaryPinCode", sender: self)
    }
    
}
