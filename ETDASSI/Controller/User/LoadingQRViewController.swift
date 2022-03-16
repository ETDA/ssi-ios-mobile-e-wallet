//
//  LoadingQRViewController.swift
//  ETDASSI
//
//  Created by Finema on 16/9/2564 BE.
//

import Foundation
import UIKit
import SwiftyJSON
import RealmSwift
import LocalAuthentication

class LoadingQRViewController : UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var callAPI : APIManager?
    var cid : String = ""
    var context: LAContext?
    var documentName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callAPI = APIManager()
        self.cid = UserDefaults.standard.string(forKey: "CID") ?? ""
        
        if(self.cid != ""){
            context = LAContext()
            var error: NSError?
            print("goToShowQR")
            if context!.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Identify yourself!"
                context!.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                    success, authenticationError in
                    DispatchQueue.main.async {
                        if success {
                            self.callAPI?.verifyVCDocQR(cid: self.cid,context:self.context, onSuccess: { qrModel in
                                    self.performSegue(withIdentifier: "goToShowQR", sender: qrModel )
                                }, onFailure: { errorResponse in
                                   
                                    self.navigationController?.popViewController(animated: true)
                                })
                        } else {
                            self.navigationController?.popViewController(animated: true)
                            // error
                        }
                    }
                }
            } else {
                self.navigationController?.popViewController(animated: true)
                // no biometry
            }
            
            
//            self.callAPI?.verifyVCDocQR(cid: self.cid, onSuccess: { qrModel in
//                    self.performSegue(withIdentifier: "goToShowQR", sender: qrModel )
//
//                }, onFailure: { errorResponse in
//
//                    self.navigationController?.popViewController(animated: true)
//                })
        
        }else{
            self.navigationController?.popViewController(animated: true)
        }
//        if(self.dataRequest != ""){
//            getDataRequest(dataRequest: dataRequest)
//        }else{
//            goToMain()
//        }
        
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToShowQR"){
            let destination = segue.destination as? ScanDocumentViewController
            destination?.modelQRLoading = sender as? QRModel
            destination?.documentName = documentName
        }
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

struct QRModel : Encodable {
    var operation: String
    var endpoint: String
}
