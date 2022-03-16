//
//  RegisterDopaViewController.swift
//  ETDASSI
//
//  Created by Finema on 14/6/2564 BE.
//

import UIKit

class RegisterDopaViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var checkDopaBtn: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var idCardTextField: UITextField!
    @IBOutlet weak var laserIDTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var lastnameErrorLabel: UILabel!
    @IBOutlet weak var birthdateErrorLabel: UILabel!
    @IBOutlet weak var idCardErrorLabel: UILabel!
    @IBOutlet weak var backIdCardErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    var datePicker = UIDatePicker()
    var activeTextField: UITextField?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        checkDopaBtn.layer.cornerRadius = 5
        checkDopaBtn.setTitle("ตรวจสอบข้อมูล", for: .normal)
        self.hideKeyboardWhenTappedAround()
        //        checkDopaBtn.isEnabled = false
        self.addDatePicker()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        checkDopaBtn.isEnabled = false
        checkDopaBtn.backgroundColor = UIColor(rgb: 0xD0D0D0)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.topItem?.title = " "
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    
    func checkDopa() {
        if isAllTextFieldValid() {
        
         let idCardTextFieldString : String = idCardTextField.text! as String
         let idCardTextFieldValue : String = idCardTextFieldString.replacingOccurrences(of: "-", with: "")
         let laserIDTextFieldString : String = laserIDTextField.text! as String
        let laserIDTextFieldValue  : String = laserIDTextFieldString.replacingOccurrences(of: "-", with: "")
 
        UserDefaults.standard.set(nameTextField.text, forKey: "first_name")
        UserDefaults.standard.set(lastNameTextField.text, forKey: "last_name")
        UserDefaults.standard.set(birthdayTextField.text, forKey: "date_of_birth")
        UserDefaults.standard.set(idCardTextFieldValue, forKey: "id_card_no")
        UserDefaults.standard.set(laserIDTextFieldValue, forKey: "laser_id")
        UserDefaults.standard.set(emailTextField.text, forKey: "email")

        UserDefaults.standard.set("REGISTER_DETAIL", forKey: "Navigate_Flow")
        
            
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoadingViewController") as! LoadingViewController
        
        self.present(vc, animated: true)
        
//        self.present(vc, animated: true) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.dismiss(animated: true) {
//                    self.performSegue(withIdentifier: "goToRegisterOTP", sender: self)
//
//                }
//
//            }
//        }
        }else{
            
        }
        
    }
    
    func addDatePicker() {
        //Formate Date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(touchCancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(touchDoneDatePicker))

        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        birthdayTextField.inputAccessoryView = toolbar
        birthdayTextField.inputView = datePicker
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToRegisterOTP" {
            let vc = segue.destination as! RegisterOTPViewController
            vc.email = self.emailTextField.text
            
            
        }
    }
    
    @objc func touchDoneDatePicker() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        birthdayTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func touchCancelPicker() {
        self.view.endEditing(true)
    }
    
    func matchingStrings(regex: String,inputValue: String) -> [String] {
           guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
           let results = regex.matches(in: inputValue,
                                            range: NSRange(inputValue.startIndex..., in: inputValue))
           return results.map {
                        String(inputValue[Range($0.range, in: inputValue)!])
           }
   }
    
    func checkRegex(type: String,textField: UITextField) -> Bool{


        if(type == "Thai"){
            let inputValue : String = textField.text! as String;
            print("inputValue textField",textField.text!)
            let pattern = "^[ก-๙]*"
            let test = matchingStrings(regex: pattern, inputValue: inputValue)[0];
            print(test.count)
            print(inputValue.count)
            if(inputValue.count > 0){
                if(test.count != inputValue.count){
                    return true
                } else {
                    return false
                }
            }  else{
                return false
            }
        }
        if(type == "idCard"){
            

            let inputValue : String = textField.text! as String ;
            
            let lastCharacter  = inputValue.suffix(1)
            if (!"0123456789".contains(lastCharacter)) {
                let index = inputValue.count-1
                let substring1 = inputValue.substring(to: index)
                textField.text = substring1;

            } else {

                var newString   = inputValue.replacingOccurrences(of: "-", with: "")
                if(newString.count <= 13){
                    if (newString.count > 1) {
                         newString.insert(
                            "-", at:newString.index(newString.startIndex, offsetBy: 1)
                        )
                    }
                    if (newString.count > 6) {
                         newString.insert(
                            "-", at:newString.index(newString.startIndex, offsetBy: 6)
                        )
                      
                    }
                    if (newString.count > 12) {
                         newString.insert(
                            "-", at:newString.index(newString.startIndex, offsetBy: 12)
                        )
                       
                    }
                    if (newString.count > 15) {
                         newString.insert(
                            "-", at:newString.index(newString.startIndex, offsetBy: 15)
                        )
                        
                    }
                    textField.text = newString;
                    if(newString.count == 17){
 
                        return false
                    } else {
 
                        return true
                    }
 
                }else{
                    let substring1 = inputValue.substring(to: 17)
                    textField.text = substring1;
                    return false
                }
             }
        }
        
        if(type == "laserCard"){
            let inputValue : String = textField.text! as String ;
            let lastCharacter  = inputValue.suffix(1)
            if (!"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".contains(lastCharacter)) {
                let index = inputValue.count-1
                let substring1 = inputValue.substring(to: index)
                textField.text = substring1;
            } else {
                var newString   = inputValue.replacingOccurrences(of: "-", with: "")
                 
                if(newString.count < 12){
                    if (newString.count > 3) {
                         newString.insert(
                            "-", at:newString.index(newString.startIndex, offsetBy: 3)
                        )
                    }
                    if (newString.count > 11) {
                         newString.insert(
                            "-", at:newString.index(newString.startIndex, offsetBy: 11)
                        )
                      
                    }
                    textField.text = newString;
                    if(inputValue.count == 12){
                        return false
                        } else {
                        return true
                    }
                }else{
                    let substring1 = inputValue.substring(to: 14)
                    textField.text = substring1;
                    return false
                }
            }
        }
        
        
        return false
    }
     
    func isAllTextFieldValid() -> Bool {
        if !isTextFieldValid(textField: nameTextField){

            nameErrorLabel.isHidden = true //false
            
            nameTextField.layer.borderColor = UIColor(rgb: 0x707070).cgColor
            nameTextField.textColor = UIColor.label
            
        }else{
            
            if(!self.checkRegex(type: "Thai",textField: self.nameTextField)){
                nameErrorLabel.isHidden = true
                
                nameTextField.layer.borderColor = UIColor(rgb: 0x707070).cgColor
                nameTextField.textColor = UIColor.label
                
                
            } else {
                nameErrorLabel.isHidden = false
                nameTextField.layer.borderColor = UIColor.red.cgColor
                nameTextField.textColor = UIColor.red
            }
           
        }
        
        if !isTextFieldValid(textField: lastNameTextField) {
            lastnameErrorLabel.isHidden = true //false
            lastNameTextField.layer.borderColor = UIColor(rgb: 0x707070).cgColor
            lastNameTextField.textColor = UIColor.label
        }else{
            if(!self.checkRegex(type: "Thai",textField: self.lastNameTextField)){
                lastnameErrorLabel.isHidden = true
                lastNameTextField.layer.borderColor = UIColor(rgb: 0x707070).cgColor
                lastNameTextField.textColor = UIColor.label
                
            } else {
                lastnameErrorLabel.isHidden = false
                lastNameTextField.layer.borderColor = UIColor.red.cgColor
                lastNameTextField.textColor = UIColor.red
            }
        }
        
        if !isTextFieldValid(textField: birthdayTextField) {
            birthdateErrorLabel.isHidden = true //false
        }else{
            birthdateErrorLabel.isHidden = true
        }
        if !isTextFieldValid(textField: idCardTextField) {
            
            idCardErrorLabel.isHidden = true //false
            idCardTextField.layer.borderColor = UIColor(rgb: 0x707070).cgColor
            idCardTextField.textColor = UIColor.label
        }else{
            
            if(!self.checkRegex(type: "idCard",textField: self.idCardTextField)){
                idCardErrorLabel.isHidden = true
                idCardTextField.layer.borderColor = UIColor(rgb: 0x707070).cgColor
                idCardTextField.textColor = UIColor.label
            } else {
                idCardErrorLabel.isHidden = false
                idCardTextField.layer.borderColor = UIColor.red.cgColor
                idCardTextField.textColor = UIColor.red
            }

        }
        if !isTextFieldValid(textField: laserIDTextField) {
            backIdCardErrorLabel.isHidden = true //false
            laserIDTextField.layer.borderColor = UIColor(rgb: 0x707070).cgColor
            laserIDTextField.textColor = UIColor.label
        }else{
            
            if(!self.checkRegex(type: "laserCard",textField: self.laserIDTextField)){
                backIdCardErrorLabel.isHidden = true
                laserIDTextField.layer.borderColor = UIColor(rgb: 0x707070).cgColor
                laserIDTextField.textColor = UIColor.label
            } else {
                backIdCardErrorLabel.isHidden = false
                laserIDTextField.layer.borderColor = UIColor.red.cgColor
                laserIDTextField.textColor = UIColor.red

            }
            let newString = laserIDTextField.text
            self.laserIDTextField.text = newString?.uppercased()

        }
        if !isTextFieldValid(textField: emailTextField) {
            emailErrorLabel.isHidden = true //false
        }else{
            emailErrorLabel.isHidden = true
        }
        
        if !isTextFieldValid(textField: nameTextField) ||
            !isTextFieldValid(textField: lastNameTextField) ||
            !isTextFieldValid(textField: birthdayTextField) ||
            !isTextFieldValid(textField: idCardTextField) ||
            !isTextFieldValid(textField: laserIDTextField) ||
            !isTextFieldValid(textField: emailTextField) ||
            self.checkRegex(type: "laserCard",textField: self.laserIDTextField) ||
            self.checkRegex(type: "idCard",textField: self.idCardTextField) ||
            self.checkRegex(type: "Thai",textField: self.nameTextField) ||
            self.checkRegex(type: "Thai",textField: self.lastNameTextField)
        {
            return false
        }else{
       
            return true
            
        }
        
        return true
    }

    
    func isTextFieldValid(textField: UITextField) -> Bool {
        
        if textField.text == "" {
            return false
        }
 
        return true
    }
    
 

    
    
    @IBAction func CheckDopa(_ sender: Any) {
        checkDopa()
    }
    
    @IBAction func touchCalendarButton(_ sender: Any) {
        self.birthdayTextField.becomeFirstResponder()
    }
    
    @IBAction func touchBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
//        print(activeTextField!.convert(activeTextField!.bounds, to: nil))
//        print(UIScreen.main.bounds.height / 2)
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let activeTextField = activeTextField {
            if self.view.frame.origin.y == 0 && activeTextField.convert(activeTextField.bounds, to: nil).minY > (UIScreen.main.bounds.height / 2) {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
   
    
    // MARK: TextField delegate
    
   

    func textFieldDidChangeSelection(_ textField: UITextField) {

        if isAllTextFieldValid() {
            checkDopaBtn.isEnabled = true
            checkDopaBtn.backgroundColor = UIColor(rgb: 0x0A214A)
        }else{
            checkDopaBtn.isEnabled = false
            checkDopaBtn.backgroundColor = UIColor(rgb: 0xD0D0D0)
            
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
         isAllTextFieldValid()
         activeTextField = nil

    }
     
}
