//
//  RegisterOTPViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 18/8/2564 BE.
//

import Foundation
import UIKit

class RegisterOTPViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var lblNewCounterAgain: UILabel!
    @IBOutlet weak var lblSendAgain: UIButton!
    
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    let RED_TEXTFIELD = UIColor(rgb: 0xFF4242)
    let BLUE_TEXTFIELD = UIColor(rgb: 0x40C2D3)
    let GREY_TEXTFIELD = UIColor(rgb: 0xD0D0D0)
    
    var timer: Timer?
    
    
    
    
    

    static var  timeDurationInBackground = 0
    var backgroundStartDate = Date()
    static var startTimeLimit = 600
    
    static var timeDurationInBackground2 = 0
    var backgroundStartDate2 = Date()
    static var startTimeLimitSendAgain2 = 180
    
    
    
    
    var  minute2: String = ""
    var second2: String = ""
    
    var timerAgain:Timer?
    var timeLimit = 600//180
    var timeLimitSendAgain = 180
    
    var email: String?
    var callAPI : APIManager?
    var userId : String?
    var otpNumber : String?
    var operationUser : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callAPI = APIManager()
        textFields[0].becomeFirstResponder()

        email = UserDefaults.standard.string(forKey: "email") ?? ""
        
        if email != "" {
            emailLabel.text = email
        }
        
        userId = UserDefaults.standard.string(forKey: "User_id")
        operationUser = UserDefaults.standard.string(forKey: "operation") ?? ""

    
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        self.timeLimit = RegisterOTPViewController.startTimeLimit - abs(RegisterOTPViewController.timeDurationInBackground)
     
        self.timeLimitSendAgain = RegisterOTPViewController.startTimeLimitSendAgain2 - abs(RegisterOTPViewController.timeDurationInBackground2)
        
        
        setDefaultTimeWhenload()
        
        startCount3Minutes()

    }
    
    @objc func appMovedToBackground() {
        gameStart()
    }
    

   @objc func appCameToForeground() {
       gameEnd()
   }
    
    func setDefaultTimeWhenload(){
        if(timeLimit > 0) {
            let minute = String(format: "%02d", timeLimit / 60)
            let second = String(format: "%02d", timeLimit % 60)
            countDownLabel.text = "\(minute):\(second)"
            timeLimit -= 1
        }else{
            countDownLabel.text = "00:00"
        }
        
        if(timeLimitSendAgain >= 0) {
            minute2 = String(format: "%02d", timeLimitSendAgain / 60)
            second2 = String(format: "%02d", timeLimitSendAgain % 60)
            lblNewCounterAgain.text = "\(minute2):\(second2)"
            timeLimitSendAgain -= 1
        }
        
        if self.timeLimitSendAgain <= 1 {
            lblSendAgain.isEnabled = true
            lblSendAgain.isHidden = false
            lblNewCounterAgain.isHidden = true
            lblSendAgain.setTitle("ส่งอีกครั้ง", for: .normal)
        }
     
    }
    
    
    func gameStart() { //to background
        backgroundStartDate = Date()
        RegisterOTPViewController.startTimeLimit = self.timeLimit

        backgroundStartDate2 = Date()
        RegisterOTPViewController.startTimeLimitSendAgain2 = self.timeLimitSendAgain
    }

    func gameEnd() { // to fourground

        let numberOfSecondInBackground = round(backgroundStartDate.timeIntervalSinceNow)
        
        RegisterOTPViewController.timeDurationInBackground = Int(numberOfSecondInBackground)
  
        let numberOfSecondInBackground2 = round(backgroundStartDate2.timeIntervalSinceNow)
        RegisterOTPViewController.timeDurationInBackground2 = Int(numberOfSecondInBackground2)
    
    }
    

    func startCount3Minutes(){
        
        lblSendAgain.isHidden = true
        lblNewCounterAgain.isHidden = false

        self.timer?.invalidate()
        self.timer = Timer()
        
        self.timerAgain?.invalidate()
        self.timerAgain = Timer()
        
        timerAgain = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerSendAgain), userInfo: nil, repeats: true)

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateTimer() {
    
        countDownLabel.isHidden = false
        if(timeLimit > 0) {
            let minute = String(format: "%02d", timeLimit / 60)
            let second = String(format: "%02d", timeLimit % 60)
            countDownLabel.text = "\(minute):\(second)"
            timeLimit -= 1
        }else{
            countDownLabel.text = "00:00"
        }
    }
    
    @objc func updateTimerSendAgain() {
         countDownLabel.isHidden = false
        lblNewCounterAgain.isHidden = false
        

 
        if(timeLimitSendAgain >= 0) {
            minute2 = String(format: "%02d", timeLimitSendAgain / 60)
            second2 = String(format: "%02d", timeLimitSendAgain % 60)
            lblNewCounterAgain.text = "\(minute2):\(second2)"
            timeLimitSendAgain -= 1
        }
        
        if timeLimitSendAgain <= 1 {
            lblSendAgain.isEnabled = true
            lblSendAgain.isHidden = false
            lblNewCounterAgain.isHidden = true
            lblSendAgain.setTitle("ส่งอีกครั้ง", for: .normal)
        }else{
            lblNewCounterAgain.isHidden = false
            lblSendAgain.isEnabled = false
            lblSendAgain.isHidden = true
        }
     
    }
    
    @IBAction func touchSendAgainButton(_ sender: Any) {
    
        self.timerAgain?.invalidate()
        self.timerAgain = Timer()
        self.timeLimitSendAgain = 180
        self.timeLimit = 600
        self.sendOTP()
        
        timerAgain = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerSendAgain), userInfo: nil, repeats: true)
        

        self.timer?.invalidate()
        self.timer = Timer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
 
    }
    

    
    func verifyError() {
        for textField in textFields {
            textField.borderColor = RED_TEXTFIELD
            textField.textColor = RED_TEXTFIELD
        }
    }
    
    func verifyEmail(){
        self.callAPI?.verifyOTP(userId: userId!, otpNumber: otpNumber! , onSuccess: { responseBool in
            if(responseBool){
                
                if(self.operationUser == "RECOVERY"){
                  
                    UserDefaults.standard.set("RECOVERY_CHECK", forKey: "Navigate_Flow")
                    self.goToWelcomeBack()
                }else{
              
                    UserDefaults.standard.set("REGISTER_VERIFY_SUCCESS", forKey: "Navigate_Flow")
                    self.goToNext()
                }
            }else{
      
                if(self.operationUser == "REGISTER"){
               
                    UserDefaults.standard.set("REGISTER_VERIFY_SUCCESS", forKey: "Navigate_Flow")
                    self.goToNext()
                }
                if(self.operationUser == "RECOVERY"){
                    
                    UserDefaults.standard.set("RECOVERY_CHECK", forKey: "Navigate_Flow")
                    self.goToWelcomeBack()
                }
             
            }
        }, onFailure: { ErrorResponse in
            print("_otp_error :",ErrorResponse.message)
            print("verify email error : \(ErrorResponse.message)")
            self.displayAlert()
        })
    }
    
    func displayAlert(){
        let alert = UIAlertController(title: "Invalid OTP Number\nPlease try again", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

            self.goToVerifyOTPAgain()
            
        }))

        self.present(alert, animated: true)
    }
    
    func goToVerifyOTPAgain(){
        otpNumber = ""
        textFields[0].becomeFirstResponder()

        for textField in textFields {
            textField.text = ""
        }

    }
    
   
    

    
    func goToNext(){
//        self.performSegue(withIdentifier: "goToCheckDopa", sender: self)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
//        self.present(vc, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CheckDopaViewController") as! CheckDopaViewController
        self.present(vc, animated: true)
    }
    

    
    func goToWelcomeBack(){
        
        self.performSegue(withIdentifier: "goToWelcomeBack", sender: self)
    }
    
    func sendOTP(){
        
        //self.timeLimit = 600
    
        self.callAPI?.requestToSendEmail(operation: self.operationUser!, onSuccess: { responseJSON in
            print("send OTP : Success")
        }, onFailure: { ErrorResponse in
            print("send OTP error :\(ErrorResponse.message)")
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {

            
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        return count <= 1
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("end")
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print("change")
        if textField == textFields[0] {
            if textField.text != "" {
                textField.borderColor = BLUE_TEXTFIELD
                textField.textColor = BLUE_TEXTFIELD
                textFields[1].becomeFirstResponder()
            } else {
                textField.borderColor = GREY_TEXTFIELD
            }
        }
        if textField == textFields[1] {
            
            if textField.text != "" {
                textField.borderColor = BLUE_TEXTFIELD
                textField.textColor = BLUE_TEXTFIELD
                textFields[2].becomeFirstResponder()
            } else {
                textField.borderColor = GREY_TEXTFIELD
                textFields[0].becomeFirstResponder()
            }
            
        }
        if textField == textFields[2] {
            if textField.text != "" {
                textField.borderColor = BLUE_TEXTFIELD
                textField.textColor = BLUE_TEXTFIELD
                textFields[3].becomeFirstResponder()
            } else {
                textField.borderColor = GREY_TEXTFIELD
                textFields[1].becomeFirstResponder()
            }
        }
        if textField == textFields[3] {
            if textField.text != "" {
                textField.borderColor = BLUE_TEXTFIELD
                textField.textColor = BLUE_TEXTFIELD
                
                
            } else {
                textField.borderColor = GREY_TEXTFIELD
                textFields[2].becomeFirstResponder()
                
            }
        }
        
        otpNumber = ""
        let tNum1 : String = textFields[0].text ?? ""
        let tNum2 : String = textFields[1].text ?? ""
        let tNum3 : String = textFields[2].text ?? ""
        let tNum4 : String = textFields[3].text ?? ""
        otpNumber = tNum1+tNum2+tNum3+tNum4
        print("OTP :\(otpNumber) Count: \(otpNumber?.count)")
        if(otpNumber?.count == 4){
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.verifyEmail()
            }
            
            
        }
    }
    
}
