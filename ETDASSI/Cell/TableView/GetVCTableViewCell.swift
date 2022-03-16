//
//  GetVCTableViewCell.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 31/8/2564 BE.
//

import Foundation
import UIKit

class GetVCTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var touchDetailButton: (()->Void)?
    
    @IBAction func touchDetailButton(_ sender: Any) {
        touchDetailButton?()
    }
    
}
