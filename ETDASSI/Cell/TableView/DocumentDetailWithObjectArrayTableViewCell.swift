//
//  DocumentDetailWithObjectArrayTableViewCell.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 27/8/2564 BE.
//

import Foundation
import UIKit
import SwiftyJSON

class DocumentDetailWithObjectArrayTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var detailTableViewHeightCon: NSLayoutConstraint!
    
    var heightChange: ((CGFloat, Bool)->Void)?
    var keys = [String]()
    var values = [JSON]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
     
        
       // detailTableView.register(UINib(nibName: "DocumentDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        detailTableView.register(UINib(nibName: "DocumentDetailInnerArrayTableViewCell", bundle: nil), forCellReuseIdentifier: "InnerArrayCell")
        detailTableView.register(UINib(nibName: "DocumentDetailWithObjectArrayTableViewCell", bundle: nil), forCellReuseIdentifier: "ObjectArrayCell")
        detailTableView.dataSource = self
        detailTableView.delegate = self
        self.layoutIfNeeded()
        print("size Table\(detailTableView.contentSize)")
//        self.detailTableViewHeightCon.constant = detailTableView.contentSize.height
        
     
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
      
        self.detailTableViewHeightCon.constant = detailTableView.contentSize.height
        

//       heightChange?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let normalSize = CGFloat(100)
        var lenghtString:Int = 0
        if(values[indexPath.row].type == .string){
            let i = values[indexPath.row].string
            lenghtString = (i?.lengthOfBytes(using: .utf8))!
        }
                
        print("_type_len_",lenghtString)
        let maxRow = CGFloat(roundf(Float(lenghtString / 100)))
//        let countRow = CGFloat(1.0)
        if(maxRow > 1.0){
            print("CheckMaxRow : \(maxRow) \(values.count)")
            let fixSize = (normalSize * (maxRow * CGFloat(values.count)))
            
            switch maxRow {
            case 1..<10.0:
                if CGFloat(values.count) >= 2.0{
                    return (fixSize * CGFloat(values.count))
                }
                return (fixSize * CGFloat(2))
            case 10.0..<20.0:
                return CGFloat(CGFloat(50.0) * maxRow)
            case 20.0..<30.0:
                return CGFloat(CGFloat(40.0) * maxRow)
            case 30.0..<40.0 :
                return CGFloat(CGFloat(36.0) * maxRow)
            case 40.0..<50.0 :
                return CGFloat((CGFloat(15.0) * maxRow) * CGFloat(values.count))
            case 50.0... :
                return CGFloat((CGFloat(5.0) * maxRow) * CGFloat(values.count))
            default:
                return fixSize
            }
        }
                return normalSize//UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension //100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("ObjectArray")
        print(values[indexPath.row])
        print("Data in list \(keys.count)")
        
        
        if(values[indexPath.row].type == .string){
            let descriptionString = values[indexPath.row].string
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DocumentDetailTableViewCell
           cell.titleLabel.text = keys[indexPath.row]
                print("_type_objectarray","#1")

           cell.descriptionLabel.text = descriptionString
            cell.layoutIfNeeded()
            return cell
        } else if values[indexPath.row].type == .array {
            print("_type_objectarray","#2")
            print(keys[indexPath.row])
            print(values[indexPath.row])
            for i in values[indexPath.row].arrayValue {
                print(i.contains(where: {$0.1.type == .dictionary}))
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "InnerArrayCell") as! DocumentDetailInnerArrayTableViewCell
            cell.headerLabel.text = keys[indexPath.row]
            cell.array = values[indexPath.row].arrayValue
            cell.detailTableView.reloadData()
            /*
      
       
         
            tableView.beginUpdates()
            cell.layoutSubviews()
            cell.detailTableViewHeightCon.constant = 0//cell.detailTableView.contentSize.height
            print("OuterArrayHeight")
            print(cell.detailTableView.contentSize.height)
            tableView.endUpdates()
            cell.heightChange = { (height, isOpen) in
                cell.detailTableViewHeightCon.constant = height
                self.layoutIfNeeded()
                self.detailTableView.beginUpdates()
                self.detailTableView.endUpdates()
                self.heightChange?(height, isOpen)
                print("OuterArrayHeight in closure")
                print(cell.detailTableView.contentSize.height)
            }
            */
            cell.layoutIfNeeded()
            return cell
            
        } else {
            print("_type_objectarray","#3")
            let value = values[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "InnerArrayCell") as! DocumentDetailInnerArrayTableViewCell
            cell.headerLabel.text = keys[indexPath.row]
            var jsonArray : [JSON] = []
            for (k,v) in value{
                jsonArray.append(JSON([
                    k : v
                ]))
            }
            cell.array = jsonArray
            cell.detailTableView.reloadData()
            /*
           
            
           
            tableView.beginUpdates()
            cell.layoutSubviews()
            cell.detailTableViewHeightCon.constant = 0//cell.detailTableView.contentSize.height
            print("JSONArrayHeight")
            tableView.endUpdates()
            cell.heightChange = { (height, isOpen) in
//                cell.detailTableViewHeightCon.constant = height
                self.layoutIfNeeded()
                self.detailTableView.beginUpdates()
                self.detailTableView.endUpdates()
                self.heightChange?(height, isOpen)
//                print("OuterArrayHeight in closure")
//                print(cell.detailTableView.contentSize.height)
            }
            */
            
            cell.layoutIfNeeded()
            return cell
        }
        

    }
    

    
}
