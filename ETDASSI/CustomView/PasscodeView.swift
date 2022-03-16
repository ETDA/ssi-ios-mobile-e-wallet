//
//  PasscodeView.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 9/6/2564 BE.
//

import Foundation
import UIKit
import LocalAuthentication

class PasscodeView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var numPadButtons: [UIButton]!
    @IBOutlet var passcodeCircleViews: [UIView]!
    @IBOutlet weak var bioMetricButton: UIButton!
    
    var biomaticFinish: (() -> Void)?
    
    var touchFullPassCode: (([String]) -> Void)?
    
    var passcode = [String]()
   
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func hideBioMetricButton() {
        bioMetricButton.isHidden = true
    }
    
    func setup() {
        let nib = UINib(nibName: "PasscodeView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        self.addSubview(view)
        checkBiomatic()
    }
    
    func reset() {
        passcode.removeAll()
        for view in passcodeCircleViews {
            view.backgroundColor = .clear
            view.borderColor = UIColor(rgb: 0x9D9D9D)
        }
    }
    
    func checkBiomatic(){
       let biometric = UserDefaults.standard.string(forKey: "Biometric")
        if(biometric == nil){
           self.hideBioMetricButton();
       }
    }
    
    @IBAction func touchBioMetricsButton(_ sender: Any) {
        let biometric = UserDefaults.standard.string(forKey: "Biometric")
        if(biometric != nil){
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Identify yourself!"

                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                    success, authenticationError in

                    DispatchQueue.main.async { [self] in
                        if success {
                            if let biomaticFinish = self.biomaticFinish {
                                biomaticFinish() // calling the closure
                            }
                        } else {
                            // error
                        }
                    }
                }
            } else {
                // no biometry
            }
        }
        
        
    }
    
    @IBAction func tapDeleteButton(_ sender: Any) {
        if passcode.count > 0 {
            
            passcodeCircleViews[passcode.count - 1].backgroundColor = .clear
            passcodeCircleViews[passcode.count - 1].borderColor = UIColor(rgb: 0x9D9D9D)
            passcode.removeLast()
            print(passcode)
        }
    }
    
    @IBAction func tapNumpadButton(_ button: UIButton) {
        guard let buttonNumberString = button.titleLabel?.text else {
            return
        }
        
        if passcode.count < 6 {
            passcode.append(buttonNumberString)
            passcodeCircleViews[passcode.count - 1].backgroundColor = UIColor(rgb: 0x40C2D3)
            passcodeCircleViews[passcode.count - 1].borderColor = UIColor(rgb: 0x40C2D3)
        }
        print(passcode)
        if passcode.count == 6 {
            touchFullPassCode?(passcode)
        }
    }
    

}
