//
//  DocumentDetailWithObjectTableViewCell.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 27/8/2564 BE.
//

import Foundation
import SwiftyJSON
import UIKit

class DocumentDetailWithObjectTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var detailTableViewHeightCon: NSLayoutConstraint!
        
    var keys = [String]()
    var values = [String]()
    
    var heightChange: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Register cell
        
        detailTableView.register(UINib(nibName: "DocumentDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        detailTableView.dataSource = self
        detailTableView.delegate = self
        self.layoutIfNeeded()
        print(detailTableView.contentSize)
        //self.detailTableViewHeightCon.constant = detailTableView.contentSize.height
        
       // detailTableView.invalidateIntrinsicContentSize()
        detailTableView.estimatedRowHeight = 83.0
        detailTableView.rowHeight = UITableView.automaticDimension
        
   
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
      
//        self.detailTableViewHeightCon.constant = detailTableView.contentSize.height
        
        var tableViewHeight: CGFloat = 0

        for section in 0..<detailTableView.numberOfSections {
            for row in 0..<detailTableView.numberOfRows(inSection: section) {
                tableViewHeight += tableView(detailTableView, heightForRowAt: IndexPath(row: row, section: section))
            }
        }

        detailTableViewHeightCon.constant = tableViewHeight

    }
//    override var intrinsicContentSize: CGSize {
//        return detailTableView.contentSize
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        let normalSize = CGFloat(83.0) //44.0,100.0
//        var lenghtString:Int = 2
//
//        print("_type_va_",values[indexPath.row])
//
//        let  i = values[indexPath.row]
//        lenghtString = (i.lengthOfBytes(using: .utf8))
//
//        print("_max_lenstring_",lenghtString)
//
//        let maxRow = CGFloat(roundf(Float(lenghtString / 100)))
//
//        print("_max_",maxRow)
//        if(maxRow > 1.0){
//            print("CheckMaxRow : \(maxRow) \(values.count)")
//            let fixSize = (normalSize * (maxRow * CGFloat(values.count)))
//            print("_max_2_","ok")
//            switch maxRow {
//            case 1..<10.0:
//                if CGFloat(values.count) >= 2.0{
//                    return (fixSize * CGFloat(values.count))
//                }
//                return (fixSize * CGFloat(2)) //
//            case 10.0..<20.0:
//                return CGFloat(CGFloat(50.0) * maxRow)
//            case 20.0..<30.0:
//                return CGFloat(CGFloat(40.0) * maxRow)
//            case 30.0..<40.0 :
//                return CGFloat(CGFloat(36.0) * maxRow)
//            case 40.0..<50.0 :
//                return CGFloat((CGFloat(15.0) * maxRow) * CGFloat(values.count))
//            case 50.0... :
//                return CGFloat((CGFloat(5.0) * maxRow) * CGFloat(values.count))
//            default:
//                return fixSize
//            }
//        }
//                return normalSize
        return 83.0//UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Innercfr")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DocumentDetailTableViewCell
        cell.titleLabel.text = keys[indexPath.row]
        cell.descriptionLabel.text = values[indexPath.row]
        
        cell.layoutIfNeeded()
        return cell
    }

}
