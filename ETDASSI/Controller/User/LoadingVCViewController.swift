//
//  LoadingVCViewController.swift
//  ETDASSI
//
//  Created by Finema on 3/9/2564 BE.
//

import Foundation
import UIKit
import SwiftyJSON
import RealmSwift
import LocalAuthentication

class LoadingVCViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var callAPI : APIManager?
    var dataRequest : String = ""
    
    var myContext: LAContext?
    var jwt: String? = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataRequest = UserDefaults.standard.string(forKey: "DATA_REQUEEST") ?? ""
        callAPI = APIManager()
        if(self.dataRequest != ""){
            getDataRequest(dataRequest: dataRequest)
        }else{
            goToMain()
        }
    }
    
    
    func getDataRequest(dataRequest : String){
            
            do{
                let dataJson = try JSON(data: dataRequest.data(using: .utf8)!)
                let operation =  dataJson["operation"].stringValue
        //        let token = dataJson!["token"].stringValue
        //        let endpoint = dataJson!["endpoint"].stringValue
                
                print("operation :\(operation)")
                
                switch operation {
                case "GET_VC" :
                    getVC(jsonData: dataJson)
                case "GET_VP_REQUEST" :
                    vpRequest(jsonData: dataJson)
                case "VERIFY_VC" :
                    verifyQR(jsonData: dataJson)
                default:
                    goToMain()
                }
            }catch{
                errorDialog()
            }
    }
    
    func errorDialog(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "ErrorDialogViewController") as! ErrorDialogViewController
        vc.modalPresentationStyle = .fullScreen
        vc.agaiAction = { [weak self] in
            vc.dismiss(animated: true,completion: nil)
            self?.navigationController?.popToRootViewController(animated: true)
        }
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
    func getVC(jsonData : JSON){
        let operation = jsonData["operation"].stringValue
        let token = jsonData["token"].stringValue
        let endpoint = jsonData["endpoint"].stringValue
        
        let context = LAContext()
        let myLocalizedReasonString = "Biometric Authentication !! "
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString){ success, evaluateError in
                DispatchQueue.main.async {
                    if(success){
                        self.callAPI?.getVC(endpoint: endpoint, token: token, operation: operation, context: context, onSuccess: { response in
                            self.performSegue(withIdentifier: "goToGetVC", sender: response)
                //            self.navigationController?.popViewController(animated: true)
                        }, onFailure: { ErrorResponse in
                            print("error GET VC : \(ErrorResponse.message)")
                            self.errorDialog()
                        })
                    }
                }
            }
            
        } else {
            // no biometry
        }
        
        
        
    }
    
    func vpRequest(jsonData : JSON){
        let endpoint = jsonData["endpoint"].stringValue
//        let realm = try! Realm()
//        var listVCDoc: [VCDocument] = []
//        try! realm.write(){
//            realm.deleteAll()
//        }
        
        self.callAPI?.getVPRequestDocument(endpoint: endpoint, onSuccess: { vpObject in
            
//            DispatchQueue.main.async {
//                let storyboard = UIStoryboard(name: "User", bundle: nil)
//                let vc = storyboard.instantiateViewController(withIdentifier: "RequestDocumentDetailViewController") as! RequestDocumentDetailViewController
//                vc.dataVP = vpObject
//                vc.listVCDoc = listVCDoc
//
//
//                self.present(vc, animated: true,completion: nil)
//            }
            
            
            self.performSegue(withIdentifier: "goToRequestVPDetail", sender: vpObject )
           // self.navigationController?.popViewController(animated: true)
        }, onFailure: { ErrorResponse in
            print("error GET VP : \(ErrorResponse.message)")
            self.errorDialog()
        })
    }
    
    func verifyQR(jsonData : JSON){
        let endpoint = jsonData["endpoint"].stringValue
        self.callAPI?.getVPVerify(url: endpoint, onSuccess: { jwt in
            self.jwt = jwt
            self.callAPI?.verifyVP(jwt: jwt, onSuccess: { responseJSON in
                self.performSegue(withIdentifier: "goToVerifyVC", sender: responseJSON )
            }, onFailure: { ErrorResponse in
                self.errorDialog()
            })
        }, onFailure: { errorResponse in
            self.errorDialog()
            
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToRequestVPDetail"{
            let destination = segue.destination as? RequestDocumentDetailViewController
            destination?.dataVP = sender as? VPDocument
//            destination?.listVCDoc = sender as? [VCDocument]
        }
        if segue.identifier == "goToGetVC"{
            let destination = segue.destination as? GetVCFromQRViewController
            destination?.listVCDoc = sender as? [VCDocument]
        }
        
        if segue.identifier == "goToVerifyVC"{
            let destination = segue.destination as? VerifyVCViewController
            destination?.jsonVerify = sender as? JSON
            destination?.jwt = jwt
        }
    }
    
    func goToMain(){
        let alert = UIAlertController(title: "QRCode Not Format", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.presentedViewController?.dismiss(animated: true, completion: {
            self.present(alert, animated: true)
        })
    }
    
    func goToMainApiFail(messageTitile:String,message:String){
        let alert = UIAlertController(title: messageTitile, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.presentedViewController?.dismiss(animated: true, completion: {
            self.present(alert, animated: true)
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
}

