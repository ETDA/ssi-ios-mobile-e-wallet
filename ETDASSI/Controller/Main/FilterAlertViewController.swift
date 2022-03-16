//
//  FilterAlertViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 27/7/2564 BE.
//

import Foundation
import UIKit

enum FilterType: String {
    case all, useable, denied
}

class FilterAlertViewController: UIViewController {

    var touchDoneButton: (([FilterType])->Void)?
    
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var useableButton: UIButton!
    @IBOutlet weak var deniedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func touchFilterButton(_ button: UIButton) {
        print(button.currentImage)
        button.isSelected.toggle()
    }
    
    @IBAction func touchDoneButton(_ sender: Any) {
        var returnValue = [FilterType]()

        if allButton.isSelected {
            returnValue.append(.all)
        }
        if useableButton.isSelected {
            returnValue.append(.useable)
        }
        if deniedButton.isSelected {
            returnValue.append(.denied)
        }
        
        touchDoneButton?(returnValue)
    }
}
