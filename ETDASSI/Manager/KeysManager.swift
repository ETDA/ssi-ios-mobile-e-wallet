//
//  KeyManager.swift
//  ETDASSI
//
//  Created by Finema on 15/6/2564 BE.
//

import Foundation
import LocalAuthentication
import SwiftyJSON

open class KeysManager {
    var idx = 0
    var pid : String
    var uuidUser : String = ""
//    static let sharedInstance = KeysManager(withTag: "etda")
    
//    self.pid = withTag
//    if UserDefaults.standard.integer(forKey: "\(pid) kidx") > 0 {
//        idx = UserDefaults.standard.integer(forKey: "\(pid) kidx")
//    } else {
//        idx = 1
//        UserDefaults.standard.set(1, forKey: "\(pid) kidx")
//        UserDefaults.standard.set(UUID().uuidString, forKey: "\(pid) uuid")
//    }
    
//    publicLabel: "co.finema.etdassi.key.public.\(pid).\(idx)",
//    privateLabel: "co.finema.etdassi.key.private.\(pid).\(idx)",
    
    open var key: EllipticCurveKeyPair.Manager?
    
    init(withTag : String) {
        self.pid = withTag
        self.uuidUser = UserDefaults.standard.string(forKey: "uuid") ?? ""
        if(self.uuidUser == ""){
            self.uuidUser = UUID().uuidString
            UserDefaults.standard.set(self.uuidUser, forKey: "uuid")
        }
        
        if UserDefaults.standard.integer(forKey: "\(pid) kidx \(self.uuidUser) uuid") > 0 {
            self.idx = UserDefaults.standard.integer(forKey: "\(pid) kidx \(self.uuidUser) uuid")
            print("DataDefault \(self.idx)")
        }else{
            self.idx = 1
            UserDefaults.standard.set(1, forKey: "\(pid) kidx \(self.uuidUser) uuid")
            print("NoDataDefault \(self.idx)")
        }
        
        key = {
            let publicAccessControl = EllipticCurveKeyPair.AccessControl(protection: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, flags: [])
            let privateAccessControl = EllipticCurveKeyPair.AccessControl(protection: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, flags: [.userPresence, .privateKeyUsage])
            let config = EllipticCurveKeyPair.Config(
                publicLabel: "public.\(self.idx).\(self.uuidUser)",
                privateLabel: "private.\(self.idx).\(self.uuidUser)",
                operationPrompt: "Sign transaction",
                publicKeyAccessControl: publicAccessControl,
                privateKeyAccessControl: privateAccessControl,
                token: .secureEnclave)
            return EllipticCurveKeyPair.Manager(config: config)
        }()
    }
    
    open var PEM : String {
        do {
            return try key?.publicKey().data().PEM ?? ""
        } catch {
            return "err : cannot get key"
        }
    }
    
    open var hash : String {
        do {
            return try key?.publicKey().data().PEM.sha256() ?? ""
        } catch {
            return "err : cannot get key"
        }
    }
    
    func getHex(context: LAContext? = nil) -> String {
        do {
            let sig = try self.sign(data: hash, context: context)
            let json = JSON([
                "key_pem": PEM,
                "key_hash": hash,
                "signature":sig
            ])
            let data = json.rawString()!.data(using: .utf8)!
            return data.hexEncodedString()
        } catch {
            return "err : cannot get key"
        }
    }
    
    func sign(data: String, context: LAContext? = nil) throws -> String {
        let digest = data.data(using: .utf8)!
        let signature = try key?.sign(digest, hash: .sha256, context: context)
        return signature!.base64EncodedString()
    }
    
    func createNewKey(){
        self.idx = self.idx + 1
        UserDefaults.standard.set(self.idx, forKey: "\(pid) kidx \(self.uuidUser) uuid")
    }
}
