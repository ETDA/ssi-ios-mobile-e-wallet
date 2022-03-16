//
//  SecureManager.swift
//  ETDASSI
//
//  Created by Finema on 15/6/2564 BE.
//

import Foundation

final class SecureManager {
    
    static let shared = SecureManager()
    private init() {}
    
    private let helper = SecureEnclaveHelper(publicLabel: "co.finema.etdassi.publicKey", privateLabel: "co.finema.etdassi.privateKey", operationPrompt: "Authenticate to continue")
    
    func deleteKeyPair() throws {
        
        try helper.deletePublicKey()
        try helper.deletePrivateKey()
    }
    
    func publicKey() throws -> String {
        
        let keys = try getKeys()
        return keys.public.hex
    }
    
    func verify(signature: Data, originalDigest: Data) throws -> Bool {
        
        let keys = try getKeys()
        return try helper.verify(signature: signature, digest: originalDigest, publicKey: keys.public.ref)
    }
    
    func sign(_ digest: Data) throws -> Data {
        let keys = try getKeys()
        let signed = try helper.sign(digest, privateKey: keys.private)
        return signed
    }
    
    @available(iOS 10.3, *)
    func encrypt(_ data: Data) throws -> Data {
        
        let keys = try getKeys()
        let signed = try helper.encrypt(data, publicKey: keys.public.ref)
        return signed
    }
    
    @available(iOS 10.3, *)
    func decrypt(_ data: Data) throws -> Data {
        
        let keys = try getKeys()
        let signed = try helper.decrypt(data, privateKey: keys.private)
        return signed
    }
    
    private func getKeys() throws -> (`public`: SecureEnclaveKeyData, `private`: SecureEnclaveKeyReference) {
        
        if let publicKeyRef = try? helper.getPublicKey(), let privateKey = try? helper.getPrivateKey() {
            
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n")
            print("Use Generated Key Reference!!")
            
            return (public: publicKeyRef, private: privateKey)
        }
        else {
            
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n")
            print("Not Found! Let's Generate Key")
            
            let accessControl = try helper.accessControl(with: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
            let keypairResult = try helper.generateKeyPair(accessControl: accessControl)
            try helper.forceSavePublicKey(keypairResult.public)
            return (public: try helper.getPublicKey(), private: try helper.getPrivateKey())
        }
    }
}
