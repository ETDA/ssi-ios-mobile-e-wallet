//
//  ScanDocumentViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 28/6/2564 BE.
//

import Foundation
import UIKit
import SwiftyJSON
import RealmSwift

class ScanDocumentViewController: UIViewController {
    
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var btnStatus: UIButton!
    var modelQRLoading : QRModel? = nil
    
    @IBOutlet weak var lblDocumentName: UILabel!
    var documentName: String = ""
    var realm = try! Realm()
    
    let BLUE_COLOR = UIColor(rgb: 0x40C2D3)
    let GREY_COLOR = UIColor(rgb: 0x9D9D9D)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            lblDocumentName.text = documentName
            
        
            if(modelQRLoading != nil){
                let cid = UserDefaults.standard.string(forKey: "CID") ?? ""
                let vcDoc = realm.objects(VCDocument.self)
                let vc = vcDoc.filter("cid = %@", cid).first
                if vc?.status == "active"{
                    btnStatus.setTitle("ใช้งานได้", for: .normal)
                    btnStatus.backgroundColor = BLUE_COLOR
                }else{
                    btnStatus.setTitle("ถูกยกเลิก", for: .normal)
                    btnStatus.backgroundColor = GREY_COLOR
                }
                
                let imageQR = generateQR(dataQr: modelQRLoading!)
                qrImageView.image = imageQR
                UserDefaults.standard.set("", forKey: "CID")
            }else{
                let alert = UIAlertController(title: "Generate QR Fail", message: nil, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.navigationController?.popToRootViewController(animated: true)
                }))
                self.presentedViewController?.dismiss(animated: true, completion: {
                    self.present(alert, animated: true)
                })
            }
            
            
//            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: #selector(ScanDocumentViewController.goBack(sender:)))
//            self.navigationController?.navigationBar.titleTextAttributes =
//            [NSAttributedString.Key.foregroundColor: UIColor.white,
//             NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
            
            
            self.navigationController?.navigationBar.topItem?.title = " " //hide the word "back"
         
          
        }
   // @objc func goBack(sender: UIBarButtonItem){
        //print("_x_","xcvxcv")
       // performSegue(withIdentifier: "goToDocumentDetail", sender: nil)
     //   self.navigationController?.popToRootViewController(animated: true)
    //}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cid = UserDefaults.standard.string(forKey: "CID") ?? ""
        if cid != "" {
            let apiManager = APIManager()
            apiManager.getVCStatusList(cids: cid, onSuccess: { response in
                for responseItem in response {
                    var tags: String = ""
                    let item = responseItem.1
                    for tag in item["tags"].arrayValue{
                        if tags == ""{
                            tags = tag.stringValue
                        }else{
                            tags = tags + " " + tag.stringValue
                        }
                    }
                    VCDocument().updateStatus(cid: item["cid"].stringValue, status: item["status"].stringValue, tags: tags )
                    
                }
            }, onFailure: { error in
                print(error)
            })
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
     
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    
    func generateQR(dataQr : QRModel) -> UIImage?{
            let jsonEncoder = JSONEncoder()
            let qrEncode = try! jsonEncoder.encode(dataQr)
            let dataQRJSON = try! JSON(data: qrEncode)
            
            let myString = "\(dataQRJSON)"
            // Get data from the string
            let data = myString.data(using: String.Encoding.ascii)
            // Get a QR CIFilter
            let qrFilter = CIFilter(name: "CIQRCodeGenerator")
            // Input the data
            qrFilter!.setValue(data, forKey: "inputMessage")
            // Get the output image
            let qrImage = qrFilter!.outputImage
            // Scale the image
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledQrImage = qrImage!.transformed(by: transform)
            // Do some processing to get the UIImage
            let context = CIContext()
            let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent)
            let processedImage = UIImage(cgImage: cgImage!)
            
            return processedImage
    }

    
    @IBAction func touchSaveButton(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(qrImageView.image!, self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
