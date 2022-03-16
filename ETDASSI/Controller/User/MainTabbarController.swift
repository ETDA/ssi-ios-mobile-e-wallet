//
//  MainTabbarController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 1/7/2564 BE.
//

import Foundation
import UIKit

class MainTabbarController: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet weak var customTabbar: CustomizedTabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        let tabBarAttributes = [NSAttributedString.Key.font:UIFont(name: "NotoSansThaiUI-Regular", size: 12)]
        for item in self.tabBar.items! {
            item.setTitleTextAttributes(tabBarAttributes as [NSAttributedString.Key : Any], for: .normal)
            
        }
        
        let navigationAttributes = [NSAttributedString.Key.font:UIFont(name: "NotoSansThaiUI-Regular", size: 12), NSAttributedString.Key.foregroundColor: UIColor(red: 255, green: 0, blue: 0)]

        self.navigationController?.navigationBar.titleTextAttributes = navigationAttributes as [NSAttributedString.Key : Any]
        
        for child in children {
            child.tabBarItem.image = child.tabBarItem.image?.withRenderingMode(.alwaysOriginal)
            child.tabBarItem.selectedImage = child.tabBarItem.selectedImage?.withRenderingMode(.alwaysOriginal)

        }
        
        customTabbar.touchMiddleButton = {
            
//            self.selectedIndex = 2
            self.performSegue(withIdentifier: "goToScanQRCode", sender: nil)
            
        }
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is ScanQRCodeTabbarTemplateViewController {
            self.performSegue(withIdentifier: "goToScanQRCode", sender: nil)
            return false
        }
        return true
    }
    
    
}
