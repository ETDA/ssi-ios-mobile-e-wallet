//
//  TableViewDateHeader.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 30/6/2564 BE.
//

import Foundation
import UIKit

class TableViewDateHeader: UIView {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        let nib = UINib(nibName: "TableViewDateHeader", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        self.addSubview(view)

    }
    
    
    
}
