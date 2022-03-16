//
//  ChooseDocumentTableViewCell.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 1/7/2564 BE.
//

import Foundation
import UIKit

class ChooseDocumentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tickBoxImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var touchMagnifier: (()->Void)?
    
    @IBAction func touchMagnifierButton(_ sender: Any) {
        touchMagnifier?()
    }
    
}
