//
//  MainAlertInfoViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 27/7/2564 BE.
//

import Foundation
import UIKit

class MainAlertInfoViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var titleString: String?
    var messageString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleString
        messageLabel.text = messageString
    }
}
