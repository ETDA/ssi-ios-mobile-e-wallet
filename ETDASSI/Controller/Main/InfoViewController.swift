//
//  InfoViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 19/7/2564 BE.
//

import Foundation
import UIKit

class InfoViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var topViewContainer: UIView!
    
    var titleString: String?
    var messageString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleString
        messageLabel.text = messageString
        self.view.layer.masksToBounds = true
    }
    
    
    
}
