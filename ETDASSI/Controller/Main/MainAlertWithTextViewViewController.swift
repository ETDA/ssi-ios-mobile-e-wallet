//
//  MainAlertWithTextViewViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 27/7/2564 BE.
//

import Foundation
import UIKit
import Presentr

class MainAlertWithTextViewViewController: UIViewController, UITextViewDelegate, PresentrDelegate {
    
    @IBOutlet weak var reasonTextView: UITextView!
    
    @IBOutlet weak var btnConfirm: UIButton!
    
    @IBOutlet weak var btnCancel: UIButton!
    

    let GREY_COLOR = UIColor(rgb: 0x9D9D9D)
    let BLUE_COLOR = UIColor(rgb: 0x0A214A)
    let LIGHT_BLUE_COLOR = UIColor(rgb: 0x40C2D3)
    
    var touchAcceptButton: (()->Void)?
    var touchCancelButton: (()->Void)?
    
    var PLACEHOLDER = "ระบุเหตุผล"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reasonTextView.text = PLACEHOLDER
        reasonTextView.textColor = .lightGray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        btnConfirm.isEnabled = false
        btnConfirm.backgroundColor = GREY_COLOR

    }
    
    @IBAction func touchAcceptButton(_ sender: Any) {
        
         self.touchAcceptButton?()
    }
    
    @IBAction func touchCancelButton(_ sender: Any) {
        self.touchCancelButton?()
    }
    
    func presentrShouldDismiss(keyboardShowing: Bool) -> Bool {
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        reasonTextView.text =  textView.text
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
        }
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == self.reasonTextView {
            self.btnConfirm.isEnabled = !textView.text.isEmpty
            
            if textView.text.isEmpty {
                btnConfirm.backgroundColor = GREY_COLOR
            }else{
                btnConfirm.backgroundColor = BLUE_COLOR
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = PLACEHOLDER
            textView.textColor = .lightGray
        }
       
    }
    
    @objc override func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
