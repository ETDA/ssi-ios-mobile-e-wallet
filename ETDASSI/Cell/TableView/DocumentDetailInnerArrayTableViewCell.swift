//
//  DocumentDetailInnerArrayTableViewCell.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 29/8/2564 BE.
//

import Foundation
import SwiftyJSON
import UIKit

class DocumentDetailInnerArrayTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var detailTableViewHeightCon: NSLayoutConstraint!
    
    var heightChange: ((CGFloat, Bool)->Void)?
    var array = [JSON]()
//    var jsonDetail:JSON? = nil
//    var keys = [String]()
//    var values = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Register cell
        detailTableView.register(UINib(nibName: "DocumentDetailInnerArrayObjectTableViewCell", bundle: nil), forCellReuseIdentifier: "InnerArrayCell")
        
//        detailTableView.register(UINib(nibName: "DocumentDetailWithObjectTableViewCell", bundle: nil), forCellReuseIdentifier: "ObjectCell")
        detailTableView.dataSource = self
        detailTableView.delegate = self
        self.layoutIfNeeded()
        print("size Table in:\(detailTableView.contentSize)")
        self.detailTableViewHeightCon.constant = detailTableView.contentSize.height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.detailTableViewHeightCon.constant = detailTableView.contentSize.height

//        heightChange?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if( jsonDetail != nil){
//            for (k,v) in jsonDetail!{
//                keys.append(k)
//                values.append(v.stringValue)
//            }
//            return keys.count
//        }else{
//
//        }
        
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let arr = array[indexPath.row]
            print("InnerArray")
            var keys = [String]()
            var values = [JSON]()
            for (key, value) in arr {
                print(key, value)
                keys.append(key)
                values.append(value)
            }
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InnerArrayCell") as! DocumentDetailInnerArrayObjectTableViewCell
            print(keys)
            print(values)
            print("_type_innerarraytableview_","#1")
            cell.keys = keys
            cell.values = values
            cell.detailTableView.reloadData()
            tableView.beginUpdates()
            cell.layoutSubviews()
            cell.detailTableViewHeightCon.constant = cell.detailTableView.contentSize.height
            print("InnerArrayHeight")
            print(cell.detailTableView.contentSize.height)
            tableView.endUpdates()
        

            
            return cell
//        }
//        }
    }
    
    @IBAction func touchHideShowButton(_ sender: Any) {
        let isOpen = detailTableViewHeightCon.constant == 0
        print("InnerArrayHeightAfterTouch \(isOpen)")
        print(detailTableView.contentSize.height)
        self.detailTableViewHeightCon.constant = isOpen ? detailTableView.contentSize.height : 0
        heightChange?(detailTableView.contentSize.height, isOpen)
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.detailTableViewHeightCon.constant = 0
//        self.detailTableView.beginUpdates()
//        self.detailTableView.endUpdates()
//        heightChange?()
//    }
    
    
    
}
