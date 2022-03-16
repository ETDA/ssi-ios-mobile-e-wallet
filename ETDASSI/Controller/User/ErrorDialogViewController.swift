//
//  ErrorDialogViewController.swift
//  ETDASSI
//
//  Created by Mee on 23/10/2564 BE.
//

import UIKit

class ErrorDialogViewController: UIViewController {

    @IBOutlet weak var againButton: UIButton!

    var agaiAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func touchAgainButton(_ sender: Any) {
        
        if let agaiAction = self.agaiAction {
            agaiAction() // calling the closure
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
