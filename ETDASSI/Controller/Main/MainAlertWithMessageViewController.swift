//
//  MainAlertWithMessageViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 2/7/2564 BE.
//

import Foundation
import UIKit

class MainAlertWithMessageViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    var titleString: String?
    var messageString: String?
    var cancelButtonString: String?
    var acceptButtonString: String?
    var acceptButtonColor: Int?
    
    var touchCancelButton: (()->Void)?
    var touchAcceptButton: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleString
        messageLabel.text = messageString
        cancelButton.setTitle(cancelButtonString, for: .normal)
        acceptButton.setTitle(acceptButtonString, for: .normal)
        if let color = acceptButtonColor {
            acceptButton.backgroundColor = UIColor(rgb: color)
        }
    }
    
    @IBAction func touchCancelButton(_ sender: Any) {
        touchCancelButton?()
    }
    
    @IBAction func touchAcceptButton(_ sender: Any) {
        touchAcceptButton?()
    }
}
