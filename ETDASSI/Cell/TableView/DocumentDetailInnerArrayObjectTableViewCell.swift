//
//  DocumentDetailInnerArrayObjectTableViewCell.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 29/8/2564 BE.
//

import Foundation
import UIKit
import SwiftyJSON

class DocumentDetailInnerArrayObjectTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var detailTableViewHeightCon: NSLayoutConstraint!
    
    
    var keys = [String]()
    var values = [JSON]()
    var heightChange: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Register cell
       detailTableView.register(UINib(nibName: "DocumentDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        detailTableView.register(UINib(nibName: "DocumentDetailWithObjectArrayTableViewCell", bundle: nil), forCellReuseIdentifier: "ObjectArrayCell")

        detailTableView.dataSource = self
        detailTableView.delegate = self
        self.layoutIfNeeded()
        print(detailTableView.contentSize)
        self.detailTableViewHeightCon.constant = 0//detailTableView.contentSize.height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("innerArray ContentSize")
        print(keys, values)
        print(detailTableView.contentSize.height)
        self.detailTableViewHeightCon.constant = detailTableView.contentSize.height

        heightChange?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if
//        if values.contains(where: {$0.type == .dictionary}) {
//
//        }
        print("InnerArray value ", values[indexPath.row])
        if values[indexPath.row].type == .string {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DocumentDetailTableViewCell
            print("_type_innerarray_","#1")
            cell.titleLabel.text = keys[indexPath.row]
            cell.descriptionLabel.text = values[indexPath.row].string
            return cell
        } else {
            let dict = values[indexPath.row].dictionaryValue
            var innerKeys = [String]()
            var innerValues = [JSON]()
            for (key, value) in dict {
                print(key, value)
                innerKeys.append(key)
                innerValues.append(value)
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectArrayCell") as! DocumentDetailWithObjectArrayTableViewCell
            print("_type_innerarray_","#2")
            print(innerKeys)
            print(innerValues)
            cell.headerLabel.text = keys[indexPath.row]
            cell.keys = innerKeys
            cell.values = innerValues
            cell.detailTableView.reloadData()
            tableView.beginUpdates()
            cell.layoutSubviews()
            cell.detailTableViewHeightCon.constant = cell.detailTableView.contentSize.height
            print("InnerArrayHeight")
            print(cell.detailTableView.contentSize.height)
            tableView.endUpdates()
//            cell.heightChange = {
//                tableView.beginUpdates()
//                tableView.endUpdates()
//                print("innerarrayHeight")
//                print(cell.detailTableViewHeightCon.constant)
//                self.heightChange?()
//            }
            

//            cell.titleLabel.text = "keys[indexPath.row]"
            
            return cell
            
        }
//        if indexPath.row % 2 == 0 {
//            
//        } else {
////
////            let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell") as! DocumentDetailWithObjectTableViewCell
////            cell.headerLabel.text = "Test"
//            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DocumentDetailTableViewCell
//
//            return cell
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.detailTableViewHeightCon.constant = 0
        self.detailTableView.beginUpdates()
        self.detailTableView.endUpdates()
        heightChange?()
    }
    
}

