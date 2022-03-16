//
//  DeniedDocumentViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 30/7/2564 BE.
//

import Foundation
import UIKit

class DeniedDocumentViewController: UIViewController {
    
    @IBOutlet weak var containerViewHeightCon: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var denyReasonTextViewHeightCon: NSLayoutConstraint!
    @IBOutlet weak var moreDocumentDetailButton: UIButton!
    @IBOutlet weak var moreDenyReasonButton: UIButton!
    
    var containerHeight: CGFloat = 0
    var notificationDocument: RejectedDocument!
    
    @IBOutlet weak var lblDocumentName: UILabel!
    
    @IBOutlet weak var txtRejectReason: UITextView!
    
    @IBOutlet weak var lblDIDNumber: UILabel!
    var listRejectedDoc : [RejectedDocument] = []
    
    var documentName: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0xFBB617), UIColor(rgb: 0xFB9317)], startPoint: .top, endPoint: .bottom)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        self.view.layoutIfNeeded()
        
        initialData()
    }
    
    func initialData(){
        
        lblDIDNumber.text = UserDefaults.standard.string(forKey: "DID_address")
        lblDocumentName.text = documentName
        
        txtRejectReason.text = notificationDocument.rejectReason
        
        print("_output_",notificationDocument.message)
        print("_output_",JWTManager.shared.getHeaderFromJWT(jwt: notificationDocument.message).rawValue)
        
    
    }
    
    @IBAction func touchMoreDocumentButton(_ button: UIButton) {
        button.isSelected.toggle()

        if button.isSelected {

            if button == moreDocumentDetailButton {

                containerViewHeightCon.constant = containerHeight
            } else {

                denyReasonTextViewHeightCon.constant = 240
            }
        } else {

            if button == moreDocumentDetailButton {

                containerViewHeightCon.constant = 0
            } else {

                denyReasonTextViewHeightCon.constant = 0
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "documentDetail" {
            let vc = segue.destination as! DocumentDetailViewController
            print("ContainerViewHeightCon")
            if(notificationDocument != nil){
                print("dataMessage : \(notificationDocument.message)")
                vc.payload = JWTManager.shared.getHeaderFromJWT(jwt: notificationDocument.message)
                vc.updateTableViewHeight = { height in
                    self.containerViewHeightCon.constant = height + 10
                    self.containerHeight = height
                }
            }else{
                vc.payload = JWTManager.shared.getHeaderFromJWT(jwt: JWTManager().testJWT)
                vc.updateTableViewHeight = { height in
                    self.containerViewHeightCon.constant = height + 10
                    self.containerHeight = height
                }
            }
        }
    }
    
}
