//
//  LoadingViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 19/7/2564 BE.
//

import Foundation
import UIKit
import Presentr
import LocalAuthentication

class LoadingViewController: UIViewController {
    let keyManager = KeysManager(withTag: "etda")
    
    @IBOutlet weak var imageView: UIImageView!
    var firstName = "เสฎฐวุฒิ"
    var lastName = "วงศ์ชัย"
    var cardIdNumber = "1410200140956"
    var backCardId = "ME0111890555"
    var email = "james.stw@finema.com"
    var birthDate = "826534696563"
    var callAPI : APIManager?
    var didAddress : String?
    var userId : String?
    let opRegister = "REGISTER"
    let opRecover = "RECOVERY"
    var context: LAContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(false, forKey: "FirstRegister")
        callAPI = APIManager()
        let userFlow = UserDefaults.standard.string(forKey: "Navigate_Flow")
        switch userFlow {
        case "REGISTER_DETAIL":
            print("_loading_","register_detail")
            firstName = UserDefaults.standard.string( forKey: "first_name")!
            lastName = UserDefaults.standard.string( forKey: "last_name")!
            birthDate = UserDefaults.standard.string( forKey: "date_of_birth")!
            cardIdNumber = UserDefaults.standard.string( forKey: "id_card_no")!
            backCardId = UserDefaults.standard.string( forKey: "laser_id")!
            email = UserDefaults.standard.string( forKey: "email")!
            registerUser()
        case "RECOVERY_CHECK":
            print("_loading_","recovery_check")
            registerRecovery()
        case "REGISTER_VERIFY_SUCCESS":
            print("_loading_","register_verify_succ")
            registerDid()
        case "BYPASS":
            print("_loading_","register_verify_BYPASS")
            CheckDopaViewController()
        case "REGISTER_SUCCESS":
            print("_loading_","REGISTER_SUCCESS")
            registerSuccess()
        default:
            print()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        rotateImage()
    }

    
    func rotateImage() {
        self.view.layoutIfNeeded()
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.imageView.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func goToVerifyEmail(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterOTPViewController") as! RegisterOTPViewController
        self.present(vc, animated: true)
    }
    
    func registerSuccess(){
        self.callAPI?.didRegister(context:self.context,onSuccess: { (responseDID) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SummaryRegisterViewController") as! SummaryRegisterViewController
            UserDefaults.standard.set(true, forKey: "FirstRegister")
            self.present(vc, animated: true);
        }, onFailure: { errorResponse in
            print("registerSuccess did error : \(errorResponse.message)")
        })
    }
    
    func goToCheckDopa(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CheckDopaViewController") as! CheckDopaViewController
        self.present(vc, animated: true)
    }
    
    func errorPopup(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterErrorViewController") as! RegisterErrorViewController
        self.present(vc, animated: true)
//        let presenter = Presentr(presentationType: .custom(width: ModalSize.custom(size: 300.0), height: ModalSize.custom(size: 350.0), center: ModalCenterPosition.center))
//        presenter.roundCorners = true
//        presenter.cornerRadius = 8.0
//        presenter.viewControllerForContext = self
//
//        self.customPresentViewController(presenter, viewController: vc, animated: true, completion: {
//
//        })
        
    }
    
    
    func registerMobile(){
        self.callAPI?.mobileRegister(idCard: self.cardIdNumber, firstName: self.firstName, lastName: self.lastName, dateOfBirth: self.birthDate, laserId: self.backCardId, email: self.email, onSuccess: { (response) in
            self.didAddress = response["DID_address"].stringValue
            self.userId = response["user_id"].stringValue
            if (self.didAddress != nil) {
                UserDefaults.standard.set(self.didAddress, forKey: "DID_address")
                
            }else{
                
            }
            
            
        }, onFailure: { errorResponse in
            print("register mobile error : \(errorResponse.message)")
        })
    }
    
    func registerUser(){
        self.callAPI?.mobileRegister(idCard: cardIdNumber, firstName: firstName, lastName: lastName, dateOfBirth: birthDate, laserId: backCardId, email: email, onSuccess: { responseUser in
            self.didAddress = responseUser["did_address"].stringValue
            self.userId = responseUser["user_id"].stringValue
                                     

            print("register user  : \(responseUser) " )
            if (self.didAddress != "") {
                UserDefaults.standard.set(self.didAddress, forKey: "DID_address")
                UserDefaults.standard.set(self.email, forKey: "email")
                UserDefaults.standard.set(self.userId, forKey: "User_id")
                UserDefaults.standard.set("RECOVERY", forKey: "operation")
                UserDefaults.standard.set("REGISTER_USER_SUCCESS", forKey: "Navigate_Flow")
                self.goToVerifyEmail()
            }else{
                
                UserDefaults.standard.set(self.email, forKey: "email")
                UserDefaults.standard.set(self.userId, forKey: "User_id")
                UserDefaults.standard.set("REGISTER", forKey: "operation")
                UserDefaults.standard.set("REGISTER_USER_SUCCESS", forKey: "Navigate_Flow")
                self.goToVerifyEmail()
            }
            
            
        }, onFailure: { errorResponse in
            print("register user error : \(errorResponse.message)")
            self.errorPopup()
        })
    }
    
    func registerDid(){
        self.callAPI?.didRegister(onSuccess: { (responseDID) in
            UserDefaults.standard.set("REGISTER_DID_SUCCESS", forKey: "Navigate_Flow")
            self.goToCheckDopa()
        }, onFailure: { errorResponse in
            print("register did error : \(errorResponse.message)")
            self.keyManager.createNewKey()
            self.errorPopup()
        })
    }
    
    func registerRecovery(){
        let context = LAContext()
        let myLocalizedReasonString = "Biometric Authentication !! "
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString){ success, evaluateError in
                DispatchQueue.main.async {
                    if(success){
                        self.callAPI?.didRecovery(context: context, onSuccess: { responseBool in
                            if(responseBool){
                                self.callAPI?.updateToken(onSuccess: { responseJson in
                                    UserDefaults.standard.set("REGISTER_DID_SUCCESS", forKey: "Navigate_Flow")
                                    
                                }, onFailure: { (error) in
                                    print("update firebase fail")
                                    self.errorPopup()
                                })
                            }else{
                                self.errorPopup()
                            }
                        }, onFailure: { ErrorResponse in
                            self.errorPopup()
                        })
                       
                    }
                }
            }
            
        } else {
            // no biometry
        }
    }
    
}
