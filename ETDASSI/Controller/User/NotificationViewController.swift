//
//  NotificationViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 15/6/2564 BE.
//

import Foundation
import RealmSwift
import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    private let dateFormatter = DateFormatter()
    private let headerDateFormatter = DateFormatter()
    private var dates: [Date] = []
    private var groupedDocument: [Date: Results<NotificationDocument>] = [:]
    
    let GREY_COLOR = UIColor(rgb: 0x9D9D9D)
    let BLUE_COLOR = UIColor(rgb: 0x0A214A)
    let YELLOW_COLOR = UIColor(rgb: 0xFBB617)
    let LIGHT_BLUE_COLOR = UIColor(rgb: 0x40C2D3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        navigationItem.backButtonTitle = ""
        
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0x40C2D3), UIColor(rgb: 0x0A214A)], startPoint: .top, endPoint: .bottom)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        

        
//        tableView.allowsSelection = true
//        tableView.allowsMultipleSelection = false
//
//        dateFormatter.calendar = Calendar(identifier: .buddhist)
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC+07")
//        dateFormatter.dateStyle = .medium
//        dateFormatter.locale = Locale(identifier: "th")
//        dateFormatter.dateFormat = "d MMM yy เวลา HH:mm"
//
//        headerDateFormatter.calendar = Calendar(identifier: .buddhist)
//        headerDateFormatter.timeZone = TimeZone.current
//        headerDateFormatter.dateStyle = .medium
//        headerDateFormatter.locale = Locale(identifier: "th")
//        headerDateFormatter.dateFormat = "d MMM yy"
    }
    
    
    
 
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
      
         self.tabBarController?.tabBar.isHidden = false //true
        

        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0x40C2D3), UIColor(rgb: 0x0A214A)], startPoint: .top, endPoint: .bottom)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        
        dateFormatter.calendar = Calendar(identifier: .buddhist)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC+07")
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "th")
        dateFormatter.dateFormat = "d MMM yy เวลา HH:mm"
        
        headerDateFormatter.calendar = Calendar(identifier: .buddhist)
        headerDateFormatter.timeZone = TimeZone.current
        headerDateFormatter.dateStyle = .medium
        headerDateFormatter.locale = Locale(identifier: "th")
        headerDateFormatter.dateFormat = "d MMM yy"

        
        dates.removeAll()
        groupedDocument.removeAll()
        
        dates = NotificationDocument.getDates()
        
        dates.reverse()
        groupedDocument = NotificationDocument.getDocuments()
        groupedDocument.reversed()
        
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NotificationDocument.readAll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPendingApprove" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let date = dates[indexPath.section]
            // TODO: safe unwrap
            let document = groupedDocument[date]![indexPath.row]

            let destinationVC = segue.destination as! PendingApproveViewController
            destinationVC.notificationDocument = document
        }
    }
    
    // MARK: UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedDocument.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = dates[section]
        return groupedDocument[date]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! NotificationTableViewCell
        let date = dates[indexPath.section]
        let document = groupedDocument[date]![indexPath.row]
        

        
        let json = JWTManager.shared.getHeaderFromJWT(jwt: document.message)
        let vcMessage = json["vc"]
        
        let decoder = JSONDecoder()
        let model = try! decoder.decode(CredentialVCDetail.self, from:vcMessage.rawData())
        
        cell.documentName.text = model.type[1]
        cell.messageLabel.text = document.body
        cell.timeLabel.text = dateFormatter.string(from: document.created)
        
        if document.signingStatus == "PENDING" {
            cell.statusButton.backgroundColor = YELLOW_COLOR
            cell.documentName.textColor = BLUE_COLOR
            cell.messageLabel.textColor = .black
            cell.timeLabel.textColor = .black
        } else if document.signingStatus == "APPROVED" {
            cell.statusButton.setTitle("ลงนาม", for: .normal)
            cell.statusButton.backgroundColor = LIGHT_BLUE_COLOR
            cell.documentName.textColor = GREY_COLOR
            cell.messageLabel.textColor = GREY_COLOR
            cell.timeLabel.textColor = GREY_COLOR
        } else {
            cell.statusButton.setTitle("ถูกยกเลิก", for: .normal)
            cell.statusButton.backgroundColor = GREY_COLOR
            cell.documentName.textColor = GREY_COLOR
            cell.messageLabel.textColor = GREY_COLOR
            cell.timeLabel.textColor = GREY_COLOR
        }
        
        return cell
    }
    
    
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 71
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let date = dates[indexPath.section]
        let document = groupedDocument[date]![indexPath.row]
        
        if document.signingStatus == "PENDING" {
            performSegue(withIdentifier: "goToPendingApprove", sender: nil)
        }
    }
    
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Test"
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let date = dates[section]
        let view = TableViewDateHeader()
        
        view.dateLabel.text = headerDateFormatter.string(from: date)

        return view
    }
    
        
    
    
}
