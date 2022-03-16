//
//  LoadingView.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 9/6/2564 BE.
//

import Foundation
import UIKit

class LoadingView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        let nib = UINib(nibName: "LoadingView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
}
