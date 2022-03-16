//
//  MainViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 7/6/2564 BE.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var startBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startBtn.layer.cornerRadius = 5
        startBtn.setTitle("เปิดใช้งาน", for: .normal)
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let initialViewController: UIViewController? = storyboard.instantiateViewController(withIdentifier: "TermAndConditionViewController")
//        guard let window = UIApplication.shared.keyWindow else { return }
//        let navigationController = UINavigationController(rootViewController: initialViewController!)
//        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
//            window.rootViewController = navigationController
//            window.makeKeyAndVisible()
//        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func startBtnTapped(_ sender: Any) {
        goToNext()
    }
    
    
    func goToNext(){
        self.performSegue(withIdentifier: "goToTermAndCondition", sender: self)
    }
}
