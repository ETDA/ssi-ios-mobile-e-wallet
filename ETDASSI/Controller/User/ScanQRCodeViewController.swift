//
//  ScanQRCodeViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 24/8/2564 BE.
//

import Foundation
import UIKit
import AVFoundation

class ScanQRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
//    weak var delegate:ScannerDelegate?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var imagePicker = UIImagePickerController()

    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var scanQRSquareImage: UIImageView!
    @IBOutlet weak var scanQRSquare: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0xFBB617), UIColor(rgb: 0xFB9317)], startPoint: .top, endPoint: .bottom)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        view.layoutIfNeeded()
        let path = UIBezierPath(rect: self.scanQRSquare.bounds)
        let rect = scanQRSquare.convert(scanQRSquareImage.frame, to: nil)
        path.append(UIBezierPath(rect: rect))
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        self.scanQRSquare.layer.mask = maskLayer
        self.scanQRSquare.clipsToBounds = true
        
        self.view.bringSubviewToFront(scanQRSquare)
        self.view.bringSubviewToFront(scanQRSquareImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.navigationController?.popViewController(animated: true)
            //self.dismiss(animated: true, completion: nil)
            
//            delegate?.onScanReady(data: stringValue)
            
            let data = stringValue
            print("dataQR : \(data)")
            UserDefaults.standard.setValue(data, forKey: "DATA_REQUEEST")
            
//            let storyboard = UIStoryboard(name: "User", bundle: nil)
//            let vc = storyboard.instantiateViewController(withIdentifier: "LoadingVCViewController") as! LoadingVCViewController
//            self.present(vc, animated: true)
            self.performSegue(withIdentifier: "goToLoadingVC", sender: nil)
            //verify vc
//            self.performSegue(withIdentifier: "goToVerifyVC", sender: nil)
        }

        //dismiss(animated: true)
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func touchChooseImageButton(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {

            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let qrcodeImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
                    let ciImage:CIImage=CIImage(image:qrcodeImg)!
                    var qrCodeLink=""
          
                    let features=detector.features(in: ciImage)
                    for feature in features as! [CIQRCodeFeature] {
                        qrCodeLink += feature.messageString!
                    }
                    
                    if qrCodeLink=="" {
                        print("nothing")
                    }else{
                        print("message: \(qrCodeLink)")
                        UserDefaults.standard.setValue(qrCodeLink, forKey: "DATA_REQUEEST")
                        self.performSegue(withIdentifier: "goToLoadingVC", sender: nil)
                    }
                }
                else{
                   print("Something went wrong")
                }
               self.dismiss(animated: true, completion: nil)
    }
    
    
}
