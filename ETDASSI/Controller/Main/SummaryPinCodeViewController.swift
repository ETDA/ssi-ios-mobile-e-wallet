//
//  SummaryPinCodeViewController.swift
//  ETDASSI
//
//  Created by Finema on 16/6/2564 BE.
//

import UIKit

class SummaryPinCodeViewController: UIViewController {
    @IBOutlet weak var startBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startBtn.layer.cornerRadius = 5
        startBtn.setTitle("เริ่มต้นใช้งาน ETDA e-Wallet", for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
}
