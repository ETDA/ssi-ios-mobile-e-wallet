//
//  DocumentDetailViewController.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 29/8/2564 BE.
//

import Foundation
import UIKit
import SwiftyJSON

class DocumentDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var detailTableView: UITableView!
    
    var payload: JSON!
    var keys = [String]()
    var values = [JSON]()
    var listVC: VCDocument?
    var keyDetail = [String]()
    var valueDetail = [JSON]()
    var valueDetailStr = [String]()
    
    var selectedCredentialSubject: JSON!
    
    var updateTableViewHeight: ((CGFloat)->Void)?
    
    var credentialVCDetail : CredentialVCDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if payload != nil  {
//            let vcMessage = payload["vc"]
//
//            let decoder = JSONDecoder()
//            credentialVCDetail = try! decoder.decode(CredentialVCDetail.self, from:vcMessage.rawData())
//
//            print("Credential : \(vcMessage)")
        
            for (key,value) in payload {
                
                   if key == "vc" {
                    for(key2,value2) in value {
                        if key2 == "credentialSubject" {
                            keys.append(key2)
                            values.append(value2)
                            if(value2.type != .string){
                                for (kDetail,vDetail) in value2.dictionaryValue{
                                    keyDetail.append(kDetail)
                                    if(vDetail.type == .string){
                                        valueDetailStr.append(vDetail.stringValue)
                                    }else{
                                        valueDetail.append(vDetail)
                                    }
                                }
                            }
                        }else{
                            continue
                        }
                    }
                   }else{
                          continue
                   }
            }
        } else {

            for(key,value) in selectedCredentialSubject {
                keys.append(key)
                values.append(value)
            }
            
        }
        
        detailTableView.reloadData()
        self.view.layoutIfNeeded()
        updateTableViewHeight?(detailTableView.contentSize.height)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(keyDetail.count > 0){
                    if(valueDetail.count > 0){
                        let i = valueDetail[indexPath.section].dictionaryValue
                        var lenghtString:Int = 0
                        for va in i {
                            lenghtString = lenghtString + (va.value.string?.lengthOfBytes(using: .utf8))!
                        }
                        let normalSize = CGFloat(valueDetail[indexPath.section].dictionaryValue.keys.count) * 100.0
                        let floatString = CGFloat(lenghtString)
                        
                        if(floatString > normalSize){
                            let maxRow = CGFloat(roundf(Float(floatString / 100.0)))
                            print("Max row : \(maxRow)")
                            
                            switch maxRow {
                            case 1..<10.0:
                                if(CGFloat(valueDetail[indexPath.section].dictionaryValue.keys.count) > 2.0){
                                    return CGFloat(valueDetail[indexPath.section].dictionaryValue.keys.count) * CGFloat((80.0 * (maxRow)))
                                }else{
                                    return CGFloat(valueDetail[indexPath.section].dictionaryValue.keys.count) * CGFloat((100.0 * (maxRow * CGFloat(1.8))))
                                }
                            case 10.0..<20.0:
                                return CGFloat(valueDetail[indexPath.section].dictionaryValue.keys.count) * CGFloat((50.0 * (maxRow)))
                            case 20.0..<30.0:
                                return CGFloat(valueDetail[indexPath.section].dictionaryValue.keys.count) * CGFloat((40.0 * (maxRow)))
                            case 30.0..<40.0 :
                                if(CGFloat(valueDetail[indexPath.section].dictionaryValue.keys.count) > 2.0){
                                    return CGFloat(CGFloat(valueDetail[indexPath.section].dictionaryValue.keys.count) * CGFloat((20.0 * (maxRow))) / (maxRow / CGFloat(valueDetail[indexPath.section].dictionaryValue.keys.count)))
                                }else{
                                    return CGFloat((36.0 * (maxRow + CGFloat(valueDetail[indexPath.section].dictionaryValue.keys.count))))
                                }
                            case 40.0..<50.0 :
                                return CGFloat((15.0 * (maxRow)) * CGFloat(valueDetail[indexPath.section].dictionaryValue.keys.count))
                            case 50.0... :
                                return CGFloat((5.0 * (maxRow)) * CGFloat(valueDetail[indexPath.section].dictionaryValue.keys.count))
                            default:
                                return normalSize
                            }
                        }
                        return normalSize
                    }
                    return UITableView.automaticDimension//
                }
                return UITableView.automaticDimension//100
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(keyDetail.count > 0){
            let key = keyDetail[indexPath.section]
            if(valueDetail.count > 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectArrayCell") as! DocumentDetailWithObjectArrayTableViewCell
                print("_type_","#1")
                var keys = [String]()
                var valueDetails:[JSON] = []
                
                if valueDetail.count > indexPath.section { //fix bug array index out of length
                    for (keyD,valueD) in valueDetail[indexPath.section].dictionaryValue{
                        keys.append(keyD)
                        valueDetails.append(valueD)
                    }
                }
    
                cell.headerLabel.isHidden = true //remove duplicate header
                cell.headerLabel.text = key
                cell.keys = keys
                cell.values = valueDetails
                cell.detailTableView.reloadData()
                tableView.beginUpdates()
                cell.layoutSubviews()
                tableView.endUpdates()
                
                return cell
            }else{
    
                print("KEY : \(key) ValueDetail \(valueDetailStr[indexPath.section])")
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DocumentDetailTableViewCell
                print("_type_","#9")
                cell.titleLabel.text = key
                cell.descriptionLabel.text =  valueDetailStr[indexPath.section]
                cell.descriptionLabel.numberOfLines = 0
          
                
                
                return cell
            }
        }else{
            let key = keys[indexPath.section]
            let value = values[indexPath.section]

            print("value :\(value)")
            
            if value.type == .string {
                // normal
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DocumentDetailTableViewCell
                print("_type_","#2")
                cell.titleLabel.text = key
                cell.descriptionLabel.text = value.string
                
                return cell
            } else {
                let dict = value.dictionaryValue
                print("dict \(dict)")
                if dict.contains(where: {$0.value.type == .array}) {

                
                    var keys = [String]()
                    var values = [JSON]()
                    for (key, value) in dict {
                        keys.append(key)
                        values.append(value)
                    }
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectArrayCell") as! DocumentDetailWithObjectArrayTableViewCell
                    print("_type_","#3")
                    cell.headerLabel.text = key
                    if payload != nil  {
                      cell.headerLabel.text = "รายละเอียด"
                    }
    //                cell.headerLabel.isHidden = true
                    return cell

                } else {
                    var keys = [String]()
                    var values = [String]()
                    var keyDetails = [String]()
    //                var valueDetails:[String] = []
                    var valueDetails:[JSON] = []
                    for (key, value) in dict {
                        keys.append(key)
                        if(value.type == .string){
                            values.append(value.stringValue)
                        }else{
                            valueDetails.append(value)
                        }
                    }
                    
                    if(valueDetails.count>0){
  
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectArrayCell") as! DocumentDetailWithObjectArrayTableViewCell
                        print("_type_","#4")
                        cell.keys = keys
                        cell.values = valueDetails
                        cell.detailTableView.reloadData()
                        tableView.beginUpdates()
                        cell.layoutSubviews()
                        tableView.endUpdates()
                        
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "ObjectCell") as! DocumentDetailWithObjectTableViewCell
                        

                        print("_type_","#5")
                        cell.keys = keys
                        cell.values = values

                        cell.detailTableView.reloadData()
                        tableView.beginUpdates()
                        cell.layoutSubviews()
                        tableView.endUpdates()
                        cell.headerLabel.text = key
                        if payload != nil  {
                          cell.headerLabel.text = "รายละเอียด"
                        }
                        
                        return cell
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !valueDetailStr.isEmpty{
            return ""
        }else{
            if(!keyDetail.isEmpty){
                return keyDetail[section]
            }else{
                return ""
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !valueDetailStr.isEmpty{
            return keys.count
        }else{
            if(keyDetail.count > 0){
                return keyDetail.count
            }
            return keys.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if(keyDetail.count > 0){
//            return keyDetail.count
//        }else{
//            return keys.count
//        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !valueDetailStr.isEmpty{
            return nil
        }else{
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
            let label = UILabel()
            label.frame = CGRect.init(x:25, y: 5, width: headerView.frame.width-15, height: headerView.frame.height-10)
            if(!keyDetail.isEmpty){
                label.text = keyDetail[section]
            }else{
                return nil
            }
            label.font = .boldSystemFont(ofSize: 16)
            label.textColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
            headerView.addSubview(label)
            return headerView
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !valueDetailStr.isEmpty{
            return 0
        }else{
            if(!keyDetail.isEmpty){
                return 50
            }else{
                return 0
            }
        }
    }
}
