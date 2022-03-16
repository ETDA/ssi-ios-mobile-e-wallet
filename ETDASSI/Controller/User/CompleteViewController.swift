//
//  CompleteViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 28/6/2564 BE.
//

import Foundation
import UIKit

enum CompleteMode: String {
    case normal, extra
}

class CompleteViewController: UIViewController {
    @IBOutlet weak var completeWithImageView: UIView!
    @IBOutlet weak var extraInformationView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var extraInformationViewHeightCon: NSLayoutConstraint!
    @IBOutlet weak var containerViewHeightCon: NSLayoutConstraint!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblDetailHeader: UILabel!
    
    var mode: CompleteMode?
    var notificationDocument: NotificationDocument!
    var header: String? = ""
    var detailHeader: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Mode")
        print(mode)
        if mode == .normal {
            extraInformationViewHeightCon.constant = 0
            extraInformationView.isHidden = true
        } else if mode == .extra {
            extraInformationViewHeightCon.constant = 90
        }
        
        if(header != ""){
            lblHeader.text = header
        }
        
        if(detailHeader != ""){
            lblDetailHeader.text = detailHeader
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "documentDetail" {
            let vc = segue.destination as! DocumentDetailViewController
            
            if(notificationDocument != nil){
                vc.payload = JWTManager.shared.getHeaderFromJWT(jwt: notificationDocument.message)
                vc.updateTableViewHeight = { height in
                    self.containerViewHeightCon.constant = height
                }
            }else{
                vc.payload = JWTManager.shared.getHeaderFromJWT(jwt: JWTManager().testJWT)
                vc.updateTableViewHeight = { height in
                    self.containerViewHeightCon.constant = height
                }
            }
        }
    }
    
    @IBAction func touchBackToMainButton(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
}
