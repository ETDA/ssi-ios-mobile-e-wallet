//
//  RequestDocumentChooseViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 28/6/2564 BE.
//

import Foundation
import UIKit

class RequestDocumentChooseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var requestDocumentTableView: UITableView!
    
    var nextImageString = "check_box_inactive"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.setGradientBackground(colors: [UIColor(rgb: 0xFBB617), UIColor(rgb: 0xFB9317)], startPoint: .top, endPoint: .bottom)
        self.navigationController?.navigationBar.titleTextAttributes =
        [NSAttributedString.Key.foregroundColor: UIColor.white,
         NSAttributedString.Key.font: UIFont(name: "NotoSansThaiUI-SemiBold", size: 21)!]
    }
    
    @IBAction func touchNextButton(_ sender: Any) {
        self.performSegue(withIdentifier: "goToExtraDetail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RequestDocumentTableViewCell
        cell.checkBoxImage.image = UIImage(named: nextImageString)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RequestDocumentTableViewCell
        if cell.checkBoxImage.image == UIImage(named: "check_box_inactive") {
            nextImageString = "check_box_active"
        } else {
            nextImageString = "check_box_inactive"
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
