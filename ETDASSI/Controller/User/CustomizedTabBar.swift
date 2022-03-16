//
//  CustomizedTabBar.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 13/8/2564 BE.
//

import Foundation

import UIKit

class CustomizedTabBar: UITabBar {

    private var middleButton = UIButton()
    
    var touchMiddleButton: (()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupMiddleButton()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden {
            return super.hitTest(point, with: event)
        }
        
        let from = point
        let to = middleButton.center

        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)) <= 39 ? middleButton : super.hitTest(point, with: event)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
    }

    func setupMiddleButton() {
        middleButton.frame.size = CGSize(width: 53, height: 53)
        middleButton.backgroundColor = .clear
        middleButton.fullRound = true
        middleButton.layer.masksToBounds = true
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
        middleButton.addTarget(self, action: #selector(touchMiddle), for: .touchUpInside)
        addSubview(middleButton)
    }

    @objc func touchMiddle() {
        touchMiddleButton?()
    }
}
