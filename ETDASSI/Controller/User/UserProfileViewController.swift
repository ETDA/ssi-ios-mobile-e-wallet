//
//  UserProfileViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 17/6/2564 BE.
//

import Foundation
import UIKit
import SwiftyJSON
import LocalAuthentication

class UserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var devicesTableView: UITableView!
    @IBOutlet weak var didLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    struct UserProfileVariable {
        static var didString:String?
        static var nameString:String?
        static var userModel:User?
    }
    
    var user: User!
    //var context : LAContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
//        UserDefaults.standard.setValue("did:idin:51e6cba4bf6c87605f4546ea26baafbb7e8dc7461f5025ccd35c39e0c6147bec", forKey: "DID_address")
        
        let did = UserDefaults.standard.string(forKey: "DID_address")!

        if !did.isEmpty {
        
           self.nameLabel.text = UserProfileVariable.nameString
           self.didLabel.text = UserDefaults.standard.string(forKey: "DID_address")
            self.user = UserProfileVariable.userModel
            
        }
        
    
        
//        let did = UserDefaults.standard.string(forKey: "DID_address")!
//
//        if !did.isEmpty {
//
//            APIManager.shared.mobileGetInfo(did: did) { data in
//                self.user = User(data: data)
//
//                self.devicesTableView.reloadData()
//
//                self.nameLabel.text = self.user.firstName + " " + self.user.lastName
//               	 self.didLabel.text = UserDefaults.standard.string(forKey: "DID_address")
//
//
//            } onFailure: { error in
//                print("_ht_err_",error)
//            self.navigationController?.popToRootViewController(animated: true)
//            }
//
//        }
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true

    }
    
  
    
    deinit {
        print("deinit UserProfile")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard user != nil else {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let device = user.devices
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DeviceTableViewCell
        cell.deviceLabel.text = device.name
        cell.locationLabel.text = device.os

        if !user.registerDate.isEmpty {
            cell.dateLabel.text = convertDateFormater(user.registerDate)
        }
        
        return cell
    }
    
    func convertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        return  dateFormatter.string(from: date!)
    }
    @IBAction func getCopiedText(_ sender: Any) {
       
        UIPasteboard.general.string = self.didLabel.text // or use  sender.titleLabel.text
        let alert = UIAlertController(title: "", message: "Copied", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
     
}

