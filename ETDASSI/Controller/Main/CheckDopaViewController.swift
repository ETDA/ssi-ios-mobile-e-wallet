//
//  CheckDopaViewController.swift
//  ETDASSI
//
//  Created by Finema on 14/6/2564 BE.
//

import UIKit

class CheckDopaViewController: UIViewController {
    @IBOutlet weak var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextBtn.layer.cornerRadius = 5
        nextBtn.setTitle("ต่อไป", for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func nextBtnTapped(_ sender: Any) {
//        if true { // backup
//            goToNext(id: "goToWelcomeBack")
//        } else {
            goToNext(id: "goToPermissionRegister")
//        }
    }
    
    
    
    func goToNext(id: String){
        self.performSegue(withIdentifier: id, sender: self)
    }
}
