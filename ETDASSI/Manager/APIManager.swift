//
//  APIManager.swift
//  ETDASSI
//
//  Created by Finema on 16/6/2564 BE.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import LocalAuthentication
import RealmSwift
import SwiftUI

enum ErrorCode : UInt{
    case unknown = 301
    case failure = 302
    case cannotAccessKey = 303
    case cannotGetNonce = 304
}

class APIManager {
    
    let keyManager = KeysManager(withTag: "etda")
    static let shared = APIManager()
    
//    let baseURL = "https://etda-ssi.finema.dev"
    let baseURL = "https://ssi-test.teda.th"
    
    func getDefaultHeaders() -> HTTPHeaders {
        return [
            "Content-Type":"application/json"
        ]
    }
    
    func getHeaders(signature: String) -> HTTPHeaders {
        return [
            "Content-Type":"application/json",
            "x-signature":signature
        ]
    }
    func getHeadersforVC(signature: String,token: String) -> HTTPHeaders {
        return [
            "Content-Type":"application/json",
            "Authorization":token,
            "x-signature":signature
        ]
    }
    
    func unknownError() -> ErrorResponse {
        return ErrorResponse(errorCode: ErrorCode.unknown.rawValue, message: "Something went wrong, please try again later")
    }

    func keyAccessError() -> ErrorResponse {
        return ErrorResponse(errorCode: ErrorCode.cannotAccessKey.rawValue, message: "Cannot access key.")
    }

    func getCIDError() -> ErrorResponse {
        return ErrorResponse(errorCode: ErrorCode.unknown.rawValue, message: "Cannot get CID.")
    }
    
    func getDIDDocError() -> ErrorResponse {
            return ErrorResponse(errorCode: ErrorCode.cannotGetNonce.rawValue, message: "Cannot get Document.")
        }
        
        func databaseError() -> ErrorResponse {
            return ErrorResponse(errorCode: ErrorCode.cannotGetNonce.rawValue, message: "Cannot get Data in Database.")
        }

    func getNonceError() -> ErrorResponse {
        return ErrorResponse(errorCode: ErrorCode.cannotGetNonce.rawValue, message: "Cannot get nonce.")
    }
    
    func request(url:String,method:HTTPMethod,parameters:Parameters?, headers:HTTPHeaders = [
        "Content-Type":"application/json"
    ], onSuccess : @escaping ((JSON) -> Void), onFailure : @escaping ((ErrorResponse) -> Void)){
        AF.request(url,method: method,parameters: parameters ?? nil,encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            print("response \(response)")
            if let statusCode = response.response?.statusCode {
                switch response.result {
                case .success(let result) :
                    let json = JSON(result)
                    if statusCode >= 200 && statusCode < 300 {
                        onSuccess(json)
                    } else {
                        let res = ErrorResponse(errorCode: ErrorCode.failure.rawValue, message: String(format: "%@ : %@", json["message"].stringValue,json["fields"]["message"].stringValue))
                        onFailure(res)
                    }
                case .failure(let error):
                    let res = ErrorResponse(errorCode: ErrorCode.failure.rawValue, message: error.localizedDescription)
                    onFailure(res)
                }
            } else {
                onFailure(self.unknownError())
            }
        }
    }
    
    func bodyBuilder(json: JSON, string: String? = nil, key: KeysManager, context: LAContext? = nil, onSuccess: @escaping (Parameters,HTTPHeaders) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        
        
        
        do {
    
            print("RAWSTRING: \(json.rawString())")
            let message = json.rawString()!.toBase64()
            let signature: String
            if let str = string {
                signature = try key.sign(data: str, context: context)
            } else {
                signature = try key.sign(data: message, context: context)
            }
            print("Body Request Header: \(signature)")
            print("Body Request Message: \(message)")
            
            onSuccess([
                "message": message
            ],self.getHeaders(signature: signature))
                
        
        } catch {
            print("_key_error_","error")
            onFailure(self.keyAccessError())
        }
            
            
            
        }
    }
    
//    func bodyBuilder(json: JSON, key: KeysManager, context: LAContext? = nil, onSuccess: @escaping (Parameters,HTTPHeaders) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
//            do {
//                let message = json.rawString()!.toBase64()
//                let signature = try key.sign(data: message, context: context)
//                onSuccess([
//                    "message": message
//                ],getHeaders(signature: signature))
//            } catch {
//                onFailure(keyAccessError())
//            }
//        }
    
    //DID_API
    func didRegister(context:LAContext? = nil,onSuccess: @escaping (ResponseDID) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
        let json = JSON([
                "operation": "DID_REGISTER",
                "public_key": keyManager.PEM,
                "key_type": "EcdsaSecp256r1VerificationKey2019"
        ])
                //old Secp256r1VerificationKey2019
                
        bodyBuilder(json: json, key: keyManager,context:context, onSuccess: {(body,header) in
            let url = String(format: "%@/did", self.baseURL)
            self.request(url: url, method:HTTPMethod.post, parameters:body, headers: header, onSuccess: {(response) in
                let didResponse = ResponseDID(data: response)
                let userID = UserDefaults.standard.string(forKey: "User_id")
                self.registerUpdateUser(didAdress: didResponse.idDID, userId: userID!,context:context, onSuccess: { responseUpdateUser in
                    let didUpdate = responseUpdateUser["did_address"].stringValue
                    let userIdUpdatte = responseUpdateUser["user_id"].stringValue
                    UserDefaults.standard.set(didUpdate, forKey: "DID_address")
                    UserDefaults.standard.set(userIdUpdatte, forKey: "User_id")
                    self.updateToken(onSuccess: { responseUpdateFirebase in
                        onSuccess(didResponse)
                    }, onFailure: { errorResponseFirebase in
                        print("update firebase error : \(errorResponseFirebase.message)")
                        onSuccess(didResponse)
                    })
                }, onFailure: { errorResponse in
                    print("update did error : \(errorResponse.message)")
                    onFailure(self.keyAccessError())
                })
            }, onFailure: {(error) in
                onFailure(error)
            })
        }, onFailure: {(error) in
            onFailure(error)
        })
    }
    
    func registerUpdateUser(didAdress: String, userId:String,context:LAContext? = nil, onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (IErrorResponse) -> Void){
        var json = JSON([
            "id": userId,
            "did_address": didAdress
        ])
        let operationUser = UserDefaults.standard.string(forKey: "operation")
        if operationUser == "RECOVERY" {
            json = JSON([
                "id": userId,
                "did_address": didAdress,
                "device": [
                    "name": UIDevice.current.name,
                    "model": UIDevice.modelName,
                    "os": UIDevice.current.systemName,
                    "os_version": UIDevice.current.systemVersion,
                    "uuid": UserDefaults.standard.string(forKey: "uuid")!
                ]])
            
        }
        print("UPDATE_USER_DID \(json)")
        
        // Need to update new device info
        
        
        
        
        bodyBuilder(json: json, key: keyManager,context:context, onSuccess: {(body,header) in
            let url = String(format: "%@/api/mobile/users/%@", self.baseURL,userId)
            self.request(url: url, method:HTTPMethod.put, parameters:body, headers: header, onSuccess: {(response) in
                onSuccess(response)
            }, onFailure: {(error) in
                onFailure(error)
            })
        }, onFailure: {(error) in
            onFailure(error)
        })
    }
    
    func registerVC(didAddress: String, context:LAContext, onSuccess: @escaping (String) -> Void, onFailure: @escaping (IErrorResponse) -> Void) {
        let url = String(format: "%@/vc", self.baseURL)
        getNonce(didAddress: didAddress) { nonce in
            
            let body: Parameters = [
                "operation": "VC_REGISTER",
                "did_address": didAddress,
                "nonce": nonce
            ]
            
            self.bodyBuilder(json: JSON(body), key: self.keyManager,context: context) { parameters, headers in
                self.request(url: url, method: .post, parameters: parameters, headers: headers, onSuccess: {(response) in
                    let cid = response["cid"].stringValue
                    onSuccess(cid)
                }, onFailure: {(error) in
                    onFailure(self.getCIDError())
                })
            } onFailure: { _ in
                onFailure(self.unknownError())
            }

        } onFailure: { _ in
            onFailure(self.unknownError())
        }
    }
        
        func getNonce(didAddress: String, onSuccess: @escaping (String) -> Void, onFailure: @escaping (IErrorResponse) -> Void){
            let url = String(format: "%@/did/%@/nonce", self.baseURL,didAddress)
            request(url: url, method:HTTPMethod.get, parameters:nil, onSuccess: {(response) in
                let nonce = response["nonce"].stringValue
                onSuccess(nonce)
            }, onFailure: {(error) in
                onFailure(self.getNonceError())
            })
        }
        
        func didAddDevice(didAddress: String, key: KeysManager, newKeyHex: String, onSuccess: @escaping (ResponseDID) -> Void, onFailure: @escaping (IErrorResponse) -> Void){
            //let did = didAddress.substring(from: 9)
            var url = String(format: "%@/api/did/%@/nonce", self.baseURL,didAddress)
            request(url: url, method:HTTPMethod.get, parameters:nil, onSuccess: {(response) in
                let nonce = response["nonce"].stringValue
                
                let json = JSON([
                    "operation": "DID_KEY_ADD",
                    "did_address":didAddress,
                    "new_key": newKeyHex,
                    "nonce":nonce
                ])
                
                self.bodyBuilder(json: json, key: key, onSuccess: {(body,header) in
                    url = String(format: "%@/did/%@/keys", self.baseURL,didAddress)
                    self.request(url: url, method:HTTPMethod.post, parameters:body, headers: header, onSuccess: {(response) in
                        let didResponse = ResponseDID(data: response)
                        onSuccess(didResponse)
                    }, onFailure: {(error) in
                        onFailure(error)
                    })
                }, onFailure: {(error) in
                    onFailure(error)
                })
            }, onFailure: {(error) in
                onFailure(self.getNonceError())
            })
        }
        
        func didRevokeDevice(didAddress: String, key: KeysManager, deviceID: String, onSuccess: @escaping (ResponseDID) -> Void, onFailure: @escaping (IErrorResponse) -> Void){
           // let did = didAddress.substring(from: 9)
            var url = String(format: "%@/api/did/%@/nonce", self.baseURL,didAddress)
                self.request(url: url, method:HTTPMethod.get, parameters:nil, onSuccess: {(response) in
                let nonce = response["nonce"].stringValue
                
                let json = JSON([
                    "operation": "DID_KEY_REVOKE",
                    "did_address":didAddress,
                    "key_id": deviceID,
                    "nonce":nonce
                ])
                
                    self.bodyBuilder(json: json, key: key, onSuccess: {(body,header) in
                        url = String(format: "%@/api/did/%@/keys/%@/revoke", self.baseURL,didAddress,deviceID)
                        self.request(url: url, method:HTTPMethod.post, parameters:body, headers: header, onSuccess: {(response) in
                            let didResponse = ResponseDID(data: response)
                            onSuccess(didResponse)
                    }, onFailure: {(error) in
                        onFailure(error)
                    })
                }, onFailure: {(error) in
                    onFailure(error)
                })
            }, onFailure: {(error) in
                onFailure(self.getNonceError())
            })
        }
        
    func didGetDocument(did: String , onSuccess: @escaping (ResponseDID) -> Void, onFailure: @escaping (IErrorResponse) -> Void) {
            let url = String(format: "%@/did/%@/document/latest", self.baseURL,did)
            request(url: url, method:HTTPMethod.get, parameters:nil, onSuccess: {(response) in
                let didResponse = ResponseDID(data: response)
                onSuccess(didResponse)
            }, onFailure: {(error) in
                onFailure(self.unknownError())
            })
    }
        
    func didContextGetDocument(did: String ,context:LAContext? = nil, onSuccess: @escaping (ResponseDID) -> Void, onFailure: @escaping (IErrorResponse) -> Void) {
        let url = String(format: "%@/did/%@/document/latest", self.baseURL,did)
        request(url: url, method:HTTPMethod.get, parameters:nil, onSuccess: {(response) in
            let didResponse = ResponseDID(data: response)
            onSuccess(didResponse)
        }, onFailure: {(error) in
            onFailure(self.unknownError())
        })
    }
    
        func didGetDocumentHistory(did: String , onSuccess: @escaping ([ResponseDIDVersion]) -> Void, onFailure: @escaping (IErrorResponse) -> Void) {
            let url = String(format: "%@/api/did/%@/document/history", self.baseURL,did)
            request(url: url, method:HTTPMethod.get, parameters:nil, onSuccess: {(response) in
                let responseDocument = ResponseDIDHistory(data: response)
                onSuccess(responseDocument.didDocument)
            }, onFailure: {(error) in
                onFailure(self.unknownError())
            })
        }
        
        func didGetDocumentVersion(did: String,version: String, onSuccess: @escaping (ResponseDIDVersion) -> Void, onFailure: @escaping (IErrorResponse) -> Void) {
            let url = String(format: "%@/api/did/%@/document/%@", self.baseURL,did,version)
            request(url: url, method:HTTPMethod.get, parameters:nil, onSuccess: {(response) in
                let keys = response["verificationMethod"].arrayValue
                var keyList : [VerificationKey] = []
                for keyData in keys {
                    let key = VerificationKey(id: keyData["id"].stringValue,
                                                type: keyData["type"].stringValue,
                                                controller: keyData["controller"].stringValue,
                                                publicKeyPem: keyData["publicKeyPem"].stringValue)
                    keyList.append(key)
                }
                
                let responseDocumentVersion = ResponseDIDVersion(id: response["id"].stringValue,
                                          type: response["type"].stringValue,
                                          controller: response["controller"].stringValue,
                                          verificationKey: keyList,
                                          version: response["version"].stringValue)
                onSuccess(responseDocumentVersion)
            }, onFailure: {(error) in
                onFailure(self.unknownError())
            })
        }
        
        //Mobile_API
        func mobileRegister(idCard: String, firstName: String, lastName: String, dateOfBirth: String, laserId: String, email: String,
                            onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
            let body:Parameters = [
                "id_card_no": idCard,
                "first_name": firstName,
                "last_name": lastName,
                "date_of_birth": dateOfBirth,
                "laser_id": laserId,
                "email": email,
                "device": [
                    "name": UIDevice.current.name,
                    "model": UIDevice.modelName,
                    "os": UIDevice.current.systemName,
                    "os_version": UIDevice.current.systemVersion,
                    "uuid": UserDefaults.standard.string(forKey: "uuid")!
                ]
            ]
            
            let url = String(format: "%@/api/mobile/users", self.baseURL)
            request(url: url, method:HTTPMethod.post, parameters:body, onSuccess: {(response) in
                onSuccess(response)
            }, onFailure: {(error) in
                onFailure(self.unknownError())
            })
        }
    
    func didRecovery(context : LAContext,onSuccess: @escaping (Bool) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
        let did = UserDefaults.standard.string(forKey: "DID_address") ?? ""
        let userId = UserDefaults.standard.string(forKey: "User_id") ?? ""
        let signature = try! keyManager.sign(data: keyManager.PEM, context: context)
        
        let bodyNewKey: Parameters = [
            "signature": signature,
            "public_key": keyManager.PEM,
            "key_type": "EcdsaSecp256r1VerificationKey2019"
        ]
        
        
        var uuidUser = UserDefaults.standard.string(forKey: "uuid") ?? ""
        if(uuidUser == ""){
            uuidUser = UUID().uuidString
            UserDefaults.standard.set(uuidUser, forKey: "uuid")
        }
        
        let bodyDevice: Parameters = [
            "name": UIDevice.current.name,
            "model": UIDevice.modelName,
            "os": UIDevice.current.systemName,
            "os_version": UIDevice.current.systemVersion,
            "uuid": uuidUser
        ]
        
        let body: Parameters = [
            "new_key": bodyNewKey,
            "device": bodyDevice
        ]
        
        
        
        
        let url = String(format: "%@/api/mobile/users/%@/recovery", self.baseURL,userId)
        print("url :\(url) \n body :\(body)")
        
        request(url: url, method:HTTPMethod.post, parameters:body, onSuccess: {(response) in
            let userId = response["user_id"].stringValue
            if(userId != ""){
                self.mobileGetDidRecovery(onSuccess: { responseDIDString in
                    self.getNonce(didAddress: did) { nonceString in
                        self.addRecoveryIdBackUp(didOld: did, didNew: responseDIDString, nonce: nonceString, context: context, onSuccess: { responseDID in
                            self.updateToken(onSuccess: { responseJson in
                                onSuccess(true)
                            }) { (error) in
                                print("error updateToken didRecovery")
                                onFailure(self.unknownError())
                            }
                        }) { (error) in
                            print("error didRecoveryIdBackup :\(error.message)")
                            onFailure(error)
                        }
                    } onFailure: { (error) in
                        print("error get nonce recovery :\(error.message)")
                        onFailure(self.unknownError())
                    }

                }) { (error) in
                    print("error get didRecovery :\(error.message)")
                    onFailure(error)
                }
            }
            
        }, onFailure: {(error) in
            print("error didRecovery :\(error.message)")
            onFailure(self.unknownError())
        })
        
    }
        
        //Backup
    func mobileBackUpWallet(did: String, context: LAContext, onSuccess: @escaping (Bool) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
        self.mobileGetDidRecovery { dataDid in
            let didNew = dataDid
            self.getNonce(didAddress: did) { (dataNonce) in
                let nonce = dataNonce
                self.addRecoveryIdBackUp(didOld: did, didNew: didNew, nonce: nonce, context: context) { didRecovery in
                    let didRecoveryNew = didRecovery
                    
                    let json = JSON([
                        "operation":"WALLET_CREATE",
                        "did_address":did
                    ])
                    
                    self.bodyBuilder(json: json, key: self.keyManager, context: context, onSuccess: {(body,header) in
                        let url = String(format: "%@/api/wallet", self.baseURL)
                        self.request(url: url, method:HTTPMethod.post, parameters:body, headers: header, onSuccess: {(response) in
                            let result = response["result"].stringValue
                            let isResult = !result.isEmpty
                            onSuccess(isResult)
                        }, onFailure: {(error) in
                            onFailure(error)
                        })
                    }, onFailure: {(error) in
                        onFailure(error)
                    })
                    
                } onFailure: { errorResponse in
                    onFailure(errorResponse)
                }
                
            } onFailure: { IErrorResponse in
                onFailure(self.getNonceError())
            }
            
        } onFailure: { IErrorResponse in
            onFailure(IErrorResponse)
        }
        
    }
    
        func mobileGetDidRecovery(onSuccess: @escaping (String) -> Void, onFailure: @escaping (ErrorResponse) -> Void) {
            let url = String(format: "%@/api/mobile/did_address", self.baseURL)
            request(url: url, method:HTTPMethod.get, parameters:nil, onSuccess: {(response) in
                let did = response["did_address"].stringValue
                onSuccess(did)
            }, onFailure: {(error) in
                onFailure(self.unknownError())
            })
        }
        
    func addRecoveryIdBackUp(didOld:String, didNew:String, nonce:String, context: LAContext, onSuccess: @escaping (String) -> Void,
                             onFailure: @escaping (ErrorResponse) -> Void){
        let jsonRecovery = JSON([
            "operation":"DID_RECOVERER_ADD",
            "did_address":didOld,
            "recoverer":didNew,
            "nonce":nonce
        ])
        
        self.bodyBuilder(json: jsonRecovery, key: self.keyManager, context: context, onSuccess: {(body,header) in
            let url = String(format: "%@/did/%@/recoverer/register", self.baseURL,didOld)
            self.request(url: url, method:HTTPMethod.post, parameters:body, headers: header, onSuccess: {(response) in
                let did = response["id"].stringValue
                onSuccess(did)
            }, onFailure: {(error) in
                onFailure(error)
            })
        }, onFailure: {(error) in
            onFailure(error)
        })
    }
        
        func mobileSignVCorVP(did: String, id: String, key: KeysManager, onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
            var contextList : [String] = []
            contextList.append("https://www.w3.org/2018/credentials/v1")
            contextList.append("https://www.w3.org/2018/credentials/examples/v1")
            
            var typeList : [String] = []
            typeList.append("VerifiableCredential")
            typeList.append("UniversityDegreeCredential")
            
            let json = JSON([
                "request_id": did,
                "request_data": [
                    "@context": contextList,
                    "type": typeList,
                    "credentialSubject":[
                        "degree": [
                            "type": "BachelorDegree",
                            "name": "Bachelor of Science and Arts"
                        ]
                    ]
                ],
                "schema_type":"UniversityDegreeCredential",
                "credential_type":"VerifiableCredential",
                "signer":did,
                "requester":did
            ])
            
            bodyBuilder(json: json, key: key, onSuccess: {(body,header) in
                let url = String(format: "%@/api/v1/mobile/%@/sign", self.baseURL,did)
                self.request(url: url, method:HTTPMethod.post, parameters:body, headers: header, onSuccess: {(response) in
                    onSuccess(response)
                }, onFailure: {(error) in
                    onFailure(error)
                })
            }, onFailure: {(error) in
                onFailure(error)
            })
        }
        
        func mobileGetListVC(did: String, onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (IErrorResponse) -> Void) {
            let url = String(format: "%@/api/v1/mobile/%@/sign", self.baseURL,did)
            request(url: url, method:HTTPMethod.get, parameters:nil, onSuccess: {(response) in
                onSuccess(response)
            }, onFailure: {(error) in
                onFailure(self.unknownError())
            })
        }
        
        func mobileGetInfoVCorVP(did: String,requestId: String, onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (IErrorResponse) -> Void) {
            let url = String(format: "%@/api/v1/mobile/%@/sign/%@", self.baseURL,did,requestId)
            request(url: url, method:HTTPMethod.get, parameters:nil, onSuccess: {(response) in
                onSuccess(response)
            }, onFailure: {(error) in
                onFailure(self.unknownError())
            })
        }
        
        func mobileGetInfo(did: String, onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (IErrorResponse) -> Void) {

            let json = JSON(did)
            
            bodyBuilder(json: json, string: did, key: keyManager, onSuccess: {(body,header) in

                let url = String(format: "%@/api/mobile/users/%@", self.baseURL,did)
                
                self.request(url: url, method:HTTPMethod.get, parameters:nil, headers: header, onSuccess: {(response) in

                    onSuccess(response)
                }, onFailure: {(error) in
                    onFailure(self.unknownError())
                })
            }, onFailure: {(error) in
                onFailure(error)
            })

        }
    

        
        func mobileUpdateSign(did: String,requestId:String, status:String, key: KeysManager, onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
            let json = JSON([
                "request_id": requestId,
                "status": status
            ])
            
            bodyBuilder(json: json, key: key, onSuccess: {(body,header) in
                let url = String(format: "%@/api/v1/mobile/%@/sign/%@", self.baseURL,did,requestId)
                self.request(url: url, method:HTTPMethod.put, parameters:body, headers: header, onSuccess: {(response) in
                    onSuccess(response)
                }, onFailure: {(error) in
                    onFailure(error)
                })
            }, onFailure: {(error) in
                onFailure(error)
            })
        }
        
        //EKYC_API
        func mobileEKYC(idCardNo:String, fristName:String, lastNamee:String, laserNo:String, dateOfBirth:String, onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
            let body: Parameters = [
                "id_card_no": idCardNo,
                "first_name": fristName,
                "last_name":lastNamee,
                "date_of_birth":dateOfBirth,
                "laser_no":laserNo,
            ]
            
            let url = String(format: "%@/api/v1/mobile/ekyc", self.baseURL)
            
            request(url: url, method:HTTPMethod.post, parameters:body, onSuccess: {(response) in
                onSuccess(response)
            }, onFailure: {(error) in
                onFailure(self.unknownError())
            })
        }
        
        //OTP
        func requestToSendEmail(operation:String, onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
            var id : String
            if(operation == "RECOVERY"){
                print("_resendotp_operation",operation)
                id = UserDefaults.standard.string(forKey: "DID_address") ?? ""
            }else{
                print("_resendotp_operation","not recovery")
                id = UserDefaults.standard.string(forKey: "User_id") ?? ""
            }
            
            
    //        let json = JSON([
    //            "operation": operation,
    //            "id": id
    //        ])
            
            print("_resendotp_get_id",id)
            
            let url = String(format: "%@/api/mobile/users/%@/otp/resend", self.baseURL,id)
            request(url: url, method:HTTPMethod.post, parameters:nil, onSuccess: {(response) in
                print("_resendotp_success",response)
                onSuccess(response)
            }, onFailure: {(error) in
                print("_resendotp_error",error)
                onFailure(self.unknownError())
            })
            
    //        bodyBuilder(json: json, key: keyManager, onSuccess: {(body,header) in
    //            let url = String(format: "%@/mobile/users/%@/otp/resend", self.baseURL,id)
    //            self.request(url: url, method:HTTPMethod.post, parameters:body, headers: header, onSuccess: {(response) in
    //                onSuccess(response)
    //            }, onFailure: {(error) in
    //                onFailure(error)
    //            })
    //        }, onFailure: {(error) in
    //            onFailure(error)
    //        })
        }
        
        func verifyOTP(userId:String, otpNumber:String, onSuccess: @escaping (Bool) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
            let body: Parameters = [
                "otp_number": otpNumber
            ]
            
            let url = String(format: "%@/api/mobile/users/%@/otp/confirm", self.baseURL,userId)
            request(url: url, method:HTTPMethod.post, parameters:body, onSuccess: {(response) in
                
                let id = UserDefaults.standard.string(forKey: "DID_address") ?? ""
                
    
                if(id != ""){
                    self.didGetDocument(did: id) { responseDID in
                        if(responseDID.recovery != ""){
                           
                            onSuccess(true)
                        }else{
                           
                            onSuccess(false)
                        }
                    } onFailure: { IErrorResponse in
                        onSuccess(false)
                    }
                }else{
                    onSuccess(false)
                }
            }, onFailure: {(error) in
                onFailure(self.unknownError())
            })
        }
        
        //Firebase
        func updateToken(onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (IErrorResponse) -> Void){
            if let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") {
                let uuidUser = UserDefaults.standard.string(forKey: "uuid")!
                
                let body: Parameters = [
                    "uuid": uuidUser,
                    "token": fcmToken
                ]
            
                let url = String(format: "%@/api/mobile/devices/%@/token", self.baseURL, uuidUser)
                request(url: url, method: HTTPMethod.put, parameters: body, onSuccess: {(response) in
                    print("updateFCM response : \(response)")
                    onSuccess(response)
                }, onFailure: {(error) in
                    onFailure(self.unknownError())
                })
            }
        }
    
    //VCRequest
    func bodyBuilderforGetVC(token: String, string: String? = nil, key: KeysManager, context: LAContext? = nil, onSuccess: @escaping (HTTPHeaders) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
        do {
            let signature: String
            signature = try key.sign(data: token, context: context)
//            if let str = string {
//                signature = try key.sign(data: str, context: context)
//            } else {
//                signature = try key.sign(data: message, context: context)
//            }
            print("Body Request Header: \(signature)")
//            print("Body Request Message: \(message)")
            
            onSuccess(getHeadersforVC(signature: signature, token: token))
        } catch {
            onFailure(keyAccessError())
        }
    }
    
    func getVC(endpoint:String, token:String, operation:String, context: LAContext, onSuccess: @escaping ([VCDocument]) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
        var countList : Int = 0
        var listVC : [VCDocument] = []
        var listVCDB : [VCDocument] = []
        let userDID = UserDefaults.standard.string(forKey: "DID_address")
        let realm = try! Realm()
        
        bodyBuilderforGetVC(token: token, key: keyManager, context: context, onSuccess: {(header) in
            let url = String(format: "%@", endpoint)
            print("Header : \(header)")
            self.request(url: url, method:HTTPMethod.get, parameters:nil, headers: header, onSuccess: {(response) in
                print("Data JWT \(response)")
                let jwtResponse = ResponseJWT(data: response)
                
                for listJWT in jwtResponse.vcsList{
                    print("Data List JWT : \(listJWT)")
                    do{
//                        let jwtString : String = listJWT
                        self.verifyVC(jwt: listJWT) { (verifyResponse) in
                            let jwtManager = JWTManager()
                            let dataCredential = jwtManager.getCredentialSchemaFromJWT(jwt: listJWT)
                            
                            let decoder = JSONDecoder()
                            
                            
//                            let model = try! decoder.decode(CredentialVC.self, from: dataCredential.rawData())
                            print("DATA JWT : \(dataCredential)")
                            let model = try! decoder.decode(CredentialVC.self, from:dataCredential.rawData())
//                            let vDataCredential = CredentialVC(iss: dataCredential["iss"].stringValue, jti: dataCredential["jti"].stringValue, vc: dataCredential["vc"] )
                            let jsonEncoder = JSONEncoder()
                            let credentialData = try! jsonEncoder.encode(model)
                            let jsonCredential = String(data: credentialData, encoding: String.Encoding.utf8)
                            
                            print("Data in JWT : \(jsonCredential!)")
                            
                            let vResult = verifyResponse["verification_result"]
                            let vCid = verifyResponse["cid"].stringValue
                            let vStatus = verifyResponse["status"].stringValue
                            let vDate = verifyResponse["issuance_date"].stringValue
                            let vType = verifyResponse["type"].arrayValue
                            let vTags = verifyResponse["tags"].stringValue
                            var listType: [String] = []
                            for vlist in vType {
                                listType.append(vlist.rawValue as! String)
                            }
                            
                            let vExp = verifyResponse["exp"].stringValue
                            let vIssuer = verifyResponse["issuer"].stringValue
                            let vHolder = verifyResponse["holder"].stringValue
                            
                            if(vResult == true){
                                if(vStatus == "active" && vHolder == userDID){
                                    let vcDocument = VCDocument()
                                    vcDocument.cid = vCid
                                    vcDocument.status = vStatus
                                    vcDocument.issuanceDate = vDate
                                    vcDocument.expirationDate = vExp
                                    vcDocument.type = listType.last!
                                    vcDocument.issuer = vIssuer
                                    vcDocument.holder = vHolder
                                    vcDocument.credentialSubject = jsonCredential!
                                    vcDocument.jwt = listJWT
                                    vcDocument.tags = vTags
                                    vcDocument.backupStatus = false
                                    
                                    listVC.append(vcDocument)
                                    
                                    let vcDoc = realm.objects(VCDocument.self)
                                    let vcDocByCid = vcDoc.filter("cid = %@", vCid)
                                    for vc in vcDocByCid{
                                        listVCDB.append(vc)
                                        break
                                    }
                                    
                                    if(listVCDB.isEmpty){
                                        realm.beginWrite()
                                        realm.add(vcDocument)
                                        try! realm.commitWrite()
                                    }
                                }
                            }else{
                                print("Data verify failed : \(verifyResponse)")
                            }
                            countList += 1
                            
                            if(countList == jwtResponse.vcsList.count){
                                let isBackup = UserDefaults.standard.bool(forKey: "isBackup")
                                print("Check Data Backup :\(isBackup)")
                                    
                                if isBackup{
                                    self.backupVC(jwt: listJWT, context: context, onSuccess: {
                                        
                                    }, onFailure: { error in
                                        print("Backup Error :\(error) ")
                                    })
                                }else{
                                    onSuccess(listVC)
                                }
                                
                                onSuccess(listVC)
                            }
                            
                        } onFailure: { (error) in
                            print("_vc_","error")
                            onFailure(error)
                        }

                    }catch{
                        print("Failed to decode JWT")
                    }
                }
            }, onFailure: {(error) in
                onFailure(error)
            })
        }, onFailure: {(error) in
            onFailure(error)
        })
    }
    
    
    
    func revokeVC(notificationDocumentID: String, cid: String, onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
        let didAddress = UserDefaults.standard.string(forKey: "DID_address")
        self.getNonce(didAddress: didAddress!) { (dataNonce) in
            let nonce = dataNonce
            let json = JSON([
                "operation": "VC_UPDATE_STATUS",
                "cid": cid,
                "did_address": didAddress!,
                "status": "revoke",
                "nonce": nonce
            ])
            self.bodyBuilder(json: json, key: self.keyManager, onSuccess: {(body, header) in
                let url = String(format: "%@/vc/status/%@", self.baseURL,cid)
                self.request(url: url, method: HTTPMethod.put, parameters: body, headers: header, onSuccess: {(response) in
                    NotificationDocument().updateStatus(id: notificationDocumentID, status: "REVOKED")
                    SignedDocument().updateStatus(id: notificationDocumentID, status: "REVOKED")
                    onSuccess(response)
                }, onFailure: { errorResponse in
                    print("revoke vc error : \(errorResponse)")
                    onFailure(errorResponse)
                })
            }, onFailure: {(error) in
                onFailure(error)
            })
        } onFailure: { IErrorResponse in
            onFailure(self.getNonceError())
        }
    }
    func getVPVerify(url: String, onSuccess: @escaping (String) -> Void, onFailure: @escaping (ErrorResponse) -> Void) {
        
        self.request(url: url, method: HTTPMethod.get, parameters: nil) {(response) in
            let jwt:String = response["jwt"].stringValue
            onSuccess(jwt)
        } onFailure: {(error) in
            print("VP Verify ERROR :\(error)")
            onFailure(error)
        }
    }
    func verifyVP(jwt: String, onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
        let body: Parameters = [
            "message": jwt
        ]
        
        let url = String(format: "%@/vp/verify", self.baseURL)
        
        self.request(url: url, method: HTTPMethod.post, parameters: body) { (response) in
            onSuccess(response)
        } onFailure: { (error) in
            onFailure(error)
        }
    }
    
    private func verifyVC(jwt:String, onSuccess: @escaping (JSON) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
        let body: Parameters = [
            "message": jwt
        ]
        
        let url = String(format: "%@/vc/verify", self.baseURL)
        
        self.request(url: url, method: HTTPMethod.post, parameters: body) { (response) in
            onSuccess(response)
        } onFailure: { (error) in
            onFailure(error)
        }
    }
    //VP
    func getVPRequestDocument(endpoint: String,onSuccess: @escaping (VPDocument) -> Void, onFailure: @escaping (IErrorResponse) -> Void){
        let url = String(format: "%@", endpoint)
        
        request(url: url, method:HTTPMethod.get, parameters:nil, onSuccess: {(response) in
            let vp = VPDocument(data: response)
            onSuccess(vp)
        }, onFailure: {(error) in
            onFailure(self.unknownError())
        })
    }
    //Verify VC Doc  context
    func verifyVCDocQR(cid:String, context:LAContext? = nil, onSuccess: @escaping (QRModel) -> Void, onFailure: @escaping (ErrorResponse) -> Void){
        let realm = try! Realm()
        var vcJwtlist :[String]? = []
        let userDID = UserDefaults.standard.string(forKey: "DID_address")
        let vcDoc = realm.objects(VCDocument.self)
        print("CID : \(cid)")
        let vcDocByCid = vcDoc.filter("cid = %@", cid).first
       
        print("VCDocQR :\(vcDocByCid)")
        if(vcDocByCid != nil){
            self.didContextGetDocument(did: userDID!,context:context, onSuccess: { responseDID in
                if(!responseDID.verificationMethods.isEmpty){
                    
                    let datetime = Date().timeIntervalSince1970
                        vcJwtlist?.append(vcDocByCid!.jwt)
                    let jwtDoc = JWTVCDoc(verifiableCredential: vcJwtlist!)
                    let jwtHeader = JWTAuthHeader(typ:"JWT",kid: responseDID.verificationMethods.first!.id)
                    let jwtPayLoad = JWTPayLoadVP(jti: cid, aud: userDID!, iss: userDID!, nbf: Int64(datetime), vp:jwtDoc)
                    let jwt = self.tokenEncodeContext(jwtHead: jwtHeader, jwtPay: jwtPayLoad,context:context)
                            
                    let json = JSON([
                        "did_address": userDID!,
                        "jwt": jwt,
                        "operation": "REQUEST_VERIFY"
                    ])
                            
                    self.bodyBuilder(json: json, key: self.keyManager,context:context, onSuccess: {(body,header) in
                        let url = String(format: "%@/api/mobile/verify", self.baseURL)
                        self.request(url: url, method:HTTPMethod.post, parameters:body, headers: header, onSuccess: {(response) in
                            
                            
                            let modelQR = QRModel(operation: response["operation"].stringValue, endpoint: response["endpoint"].stringValue)
                                onSuccess(modelQR)
                            
                            }, onFailure: {(error) in
                                onFailure(error)
                
                            })
                        }, onFailure: {(error) in
                            onFailure(error)
                    
                        })
                    }
                }) { didErrorResponse in
                    onFailure(self.getDIDDocError())
                }
        }else{
            onFailure(self.databaseError())
        }
    }
    
    func createVP(listVC: [VCDocument],dataVP: VPDocument,onSuccess: @escaping (Bool) -> Void, onFailure: @escaping (IErrorResponse) -> Void){
        let realm = try! Realm()
        var vcJwtlist :[String]? = []
        var vcListString :[String]? = []
//        var listJWTDOC :[JWTVCDoc]? = []
        var vcString:String = ""
        
        let userDID = UserDefaults.standard.string(forKey: "DID_address")
        self.didGetDocument(did: userDID!) { responseDID in
            if(!responseDID.verificationMethods.isEmpty){
                print(responseDID.verificationMethods)
                let datetime = Date().timeIntervalSince1970
                let vcDoc = realm.objects(VCDocument.self)
                
                for vc in listVC{
                    let vcDocByCid = vcDoc.filter("cid = %@", vc.cid).first
                    if(vcDocByCid != nil){
                        vcListString?.append(vc.cid)
                        vcJwtlist?.append(vcDocByCid!.jwt)
                    }
                }
                
                for vc in vcListString!{
                    if vcString == "" {
                        vcString = vc
                    }else{
                        vcString = vcString + "," + vc
                    }
                }
                
                let jwtDoc = JWTVCDoc(verifiableCredential: vcJwtlist!)
                
                let jwtHeader = JWTAuthHeader(typ:"JWT",kid: responseDID.verificationMethods.first!.id)
                
                let jwtPayLoad = JWTPayLoadVP(jti: listVC.first!.cid, aud: dataVP.verifierDid, iss: userDID!, nbf: Int64(datetime), vp:jwtDoc)
                
                let jwt = self.tokenEncode(jwtHead: jwtHeader, jwtPay: jwtPayLoad)
                
                let url = String(format: "%@",dataVP.endpoint)
                let body: Parameters = [
                    "message": jwt
                ]
                
                self.request(url: url, method: HTTPMethod.post, parameters: body) { (response) in
                    let decoder = JSONDecoder()
                    let model = try! decoder.decode(DataSourceVP.self, from:response.rawData())
                    let jsonEncoder = JSONEncoder()
                    let credentialData = try! jsonEncoder.encode(model)
                    let jsonCredential = String(data: credentialData, encoding: String.Encoding.utf8)
                    if(model.verify){
                        
                        let vpDocument = VPDocumentDB()
                        vpDocument.id = model.id
                        vpDocument.name = dataVP.name
                        vpDocument.verifierDid = dataVP.verifierDid
                        vpDocument.createdAt = dataVP.createdAt
                        vpDocument.sendAt = Int64(datetime).toISOFormat()
                        vpDocument.vpIdList = vcString
                        vpDocument.jwt = jwt
                        vpDocument.sourceVP = jsonCredential!
                        
                        realm.beginWrite()
                        realm.add(vpDocument)
                        try! realm.commitWrite()
                        
                        onSuccess(true)
                    }else{
                        onSuccess(false)
                    }
                } onFailure: { errorResponse in
                    onFailure(self.unknownError())
                }
            }else{
                print("responseDID null")
                onSuccess(false)
            }
            
        } onFailure: { errorResponse in
            onFailure(self.unknownError())
        }

    }
    
    // MARK: activate VC
    func activateVC(
        cid: String,
        jwt: String,
        context: LAContext,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (IErrorResponse) -> Void
    ) {
        let url = String(format: "%@/vc/status", self.baseURL)
        let did = UserDefaults.standard.string(forKey: "DID_address") ?? ""
        let vcHash = jwt.sha256()
        getNonce(didAddress: did) { nonce in
            let body: Parameters = [
                "operation": "VC_ADD_STATUS",
                "cid": cid,
                "status": "active",
                "did_address": did,
                "vc_hash": vcHash,
                "nonce": nonce
            ]
            

            guard let data = try? JSONSerialization.data(withJSONObject: body),
                  let json = try? JSON(data: data)
            else {
                onFailure(self.unknownError())
                return
            }
            
            

            self.bodyBuilder(json: json, key: self.keyManager,context: context) { parameters, headers in
                self.request(url: url, method: .post, parameters: parameters, headers: headers) { response in
                    onSuccess()
                } onFailure: { _ in
                    onFailure(self.unknownError())
                }

            } onFailure: { _ in
                print("error para \(self.unknownError().message)")
                onFailure(self.unknownError())
            }

        } onFailure: { _ in
            onFailure(self.unknownError())
        }
    }
    
    // MARK: approve VC

    private func generateClaim(
        message: String,
        context: LAContext,
        onSuccess: @escaping (JSON) -> Void,
        onFailure: @escaping (IErrorResponse) -> Void
    ) {
        guard let decodedJWT = message.base64Decoded(),
              let data = decodedJWT.data(using: .utf8),
              var json = try? JSON(data: data)
        else {
            onFailure(self.unknownError())
            return
        }

        // nbf
        let nbf = Int(Date().timeIntervalSince1970)
        json["nbf"] = JSON(nbf)
        // cid
        calculateCID(context: context, onSuccess: { cid in
            json["jti"] = JSON(cid)
            onSuccess(json)
        }, onFailure: { _ in
            onFailure(self.unknownError())
        })
    }
    
    private func calculateCID(
        context:LAContext,
        onSuccess: @escaping (String) -> Void,
        onFailure: @escaping (IErrorResponse) -> Void
    ) {
        let did = UserDefaults.standard.string(forKey: "DID_address") ?? ""
        registerVC(didAddress: did,context: context) { cid in
            print("CID: \(cid)")
            onSuccess(cid)
        } onFailure: { _ in
            onFailure(self.unknownError())
        }
    }
    
    private func generateApproveVCHeader(
        onSuccess: @escaping (JSON) -> Void,
        onFailure: @escaping (IErrorResponse) -> Void
    ) {
        let did = UserDefaults.standard.string(forKey: "DID_address") ?? ""
        didGetDocument(did: did) { responseDidData in
            let kid = responseDidData.verificationMethods.first?.id ?? ""
            print("KID: \(kid)")
            
            let json = JSON([
                "alg": "ES256",
                "typ": "JWT",
                "kid": kid
            ])
            onSuccess(json)
        } onFailure: { errorResponse in
            onFailure(self.unknownError())
        }

    }
    

    private func generateSignature(header: JSON, claim: JSON,context: LAContext) -> String {
        let headerString = header.rawString()?.base64Encoded(shouldRemoveWhitespaces: true) ?? ""
        let claimString = claim.rawString()?.base64Encoded(shouldRemoveWhitespaces: true) ?? ""
        let message = headerString + "." + claimString
        var signature:String
        do{
            signature = try self.keyManager.sign(data: message,context: context)
        }catch{
            do {
                signature = try self.keyManager.sign(data: message,context: context)
            } catch{
                signature = ""
            }
        }
//        do{
//            signature = try self.keyManager.sign(data: message)
//        }catch{
//            do {
//                signature = try self.keyManager.sign(data: message)
//            } catch{
//                signature = ""
//            }
//        }
        return signature

    }
    
    private func approveVC(
        url: String,
        header: JSON,
        claim: JSON,
        context: LAContext,
        onSuccess: @escaping (String) -> Void,
        onFailure: @escaping (IErrorResponse) -> Void
    ) {
        print("HEADER: \(header)")
        print("CLAIM: \(claim)")
        
        let headerString = header.rawString()?.toBase64() ?? ""
        let claimString = claim.rawString()?.toBase64() ?? ""
        print("HEADER_STRING \(headerString)")
        print("CLAIM_STRING \(claimString)")
        var message = headerString + "." + claimString
        message = message.replacingOccurrences(of: "+", with: "-")
        message = message.replacingOccurrences(of: "/", with: "_")
        message = message.replacingOccurrences(of: "=", with: "")
        print("MESSAGE \(message)")
        self.bodyBuilder(json: JSON([]), string: message, key: self.keyManager, context: context, onSuccess: { p,h in
            let signature = h.value(for: "x-signature") ?? ""
            let jwt = message + "." + signature
            print("JWT: \(jwt)")
            self.activateVC(cid: claim["jti"].stringValue, jwt: jwt, context:context) {
                
                let body: Parameters = [
                    "jwt": jwt
                ]
                print("url : \(url)")
                self.bodyBuilder(json: JSON(body), key: self.keyManager, context: context) { parameters, headers in
                    self.request(url: url, method: .post, parameters: parameters, headers: headers) { response in
                        onSuccess(jwt)
                    } onFailure: { errorResponse in
                        onFailure(self.unknownError())
                    }
                    
                } onFailure: { _ in

                    onFailure(self.unknownError())
                }
                
            } onFailure: { _ in
                onFailure(self.unknownError())
            }
        }, onFailure: {error in
            onFailure(error)
            
        })

    }

    func approveVC(
        document: NotificationDocument,
        context:LAContext,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (IErrorResponse) -> Void
    ) {
        var claim: JSON = JSON()
        var headers: JSON = JSON()
        
        generateClaim(message: document.message,context: context) { c in
            claim = c
            
            self.generateApproveVCHeader { h in
                headers = h
                
                self.approveVC(url: document.approveEndpoint, header: headers, claim: claim,context: context) { s in
                    
                    document.updateStatus(id: document.id, status: "APPROVED")
                    SignedDocument.add(notificationDoc: document, jwt: s)
                    
                    let isBackup = UserDefaults.standard.bool(forKey: "isBackup")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if isBackup {
                            self.backupVC(jwt: s, context: context, onSuccess: {
                                onSuccess()

                            }, onFailure: { error in
                                onFailure(error)
                            })
                        }else{
                            onSuccess()
                        }
                    }
                    
                }onFailure: { errorResponse in
                    onFailure(self.unknownError())
                }
                
            } onFailure: { _ in
                onFailure(self.unknownError())
            }
            
        } onFailure: { _ in
            onFailure(self.unknownError())
        }
    }
    
    // MARK: reject VC

    func rejectVC(
        document: NotificationDocument,
        reason: String,
        onSuccess: @escaping () -> Void,
        onFailure: @escaping (IErrorResponse) -> Void
    ) {
        let url = document.rejectEndpoint
        let body: Parameters = [
            "reason": reason
        ]
        bodyBuilder(
            json: JSON(body),
            key: keyManager
        ) { parameters, headers in
            self.request(url: url, method: .post, parameters: parameters, headers: headers) { response in
                // TODO
                document.updateStatus(id: document.id, status: "REJECTED")
                RejectedDocument.add(notificationDoc: document, rejectReason: reason)
                onSuccess()
            } onFailure: { errorResponse in
                onFailure(self.unknownError())
            }

        } onFailure: { _ in
            onFailure(self.unknownError())
        }

    }
    
    private func tokenEncodeContext(jwtHead : JWTAuthHeader,  jwtPay : JWTPayLoadVP,context: LAContext? = nil) -> String{
        let jsonEncoder = JSONEncoder()
        let jwtHeadData = try! jsonEncoder.encode(jwtHead)
        let jwtPayData = try! jsonEncoder.encode(jwtPay)
        let jwtHeader = try! JSON(data: jwtHeadData)
        let jwtClaim = try! JSON(data: jwtPayData)
        
    
        let headerString = jwtHeader.rawString()?.base64Encoded(shouldRemoveWhitespaces: true) ?? ""
        let claimString = jwtClaim.rawString()?.base64Encoded(shouldRemoveWhitespaces: true) ?? ""
        let value = String(format: "%@.%@", headerString, claimString)
        
        let signature = try! self.keyManager.sign(data: value,context:context)
        return String(format: "%@.%@", value,signature)
        
    }
    
    private func tokenEncode(jwtHead : JWTAuthHeader,  jwtPay : JWTPayLoadVP) -> String{
        let jsonEncoder = JSONEncoder()
        let jwtHeadData = try! jsonEncoder.encode(jwtHead)
        let jwtPayData = try! jsonEncoder.encode(jwtPay)
        let jwtHeader = try! JSON(data: jwtHeadData)
        let jwtClaim = try! JSON(data: jwtPayData)
        
    
        let headerString = jwtHeader.rawString()?.base64Encoded(shouldRemoveWhitespaces: true) ?? ""
        let claimString = jwtClaim.rawString()?.base64Encoded(shouldRemoveWhitespaces: true) ?? ""
        let value = String(format: "%@.%@", headerString, claimString)
        
        let signature = try! self.keyManager.sign(data: value)
        return String(format: "%@.%@", value,signature)
        
    }
    func backupVC(jwt: String, context: LAContext, onSuccess: @escaping () -> Void, onFailure: @escaping(IErrorResponse) -> Void){
        let jwtManager = JWTManager()
        let jwtClaim = jwtManager.getCredentialSchemaFromJWT(jwt: jwt)
        let didAddress = UserDefaults.standard.string(forKey: "DID_address") ?? ""
        let cid = jwtClaim["jti"].stringValue
        self.checkExistingVCinBackupWallet(cid: cid, context: context, onSuccess: { response in
            if response["is_exists"] == false {
                
                let payloadRequest = JSON([
                    "operation": "WALLET_VC_ADD",
                    "did_address": didAddress,
                    "jwt": jwt,
                ])
                self.bodyBuilder(json: payloadRequest, key: self.keyManager, context: context, onSuccess: { (body, header) in
                    let url = String(format: "%@/api/wallet/%@/vcs", self.baseURL, didAddress)
                    self.request(url: url, method: HTTPMethod.post, parameters: body, headers: header, onSuccess: { response in
                        onSuccess()
                        
                    }, onFailure: { errorResponse in
                        onFailure(errorResponse)
                        
                    })
                }, onFailure: {error in
                    onFailure(error)
                })
                
            }
            
        }, onFailure: { error in
            onFailure(error)
        })
    }
//    "page": 1,
//    "total": 4,
//    "limit": 30,
//    "count": 4,
    
    func restoreVC(context: LAContext, onSuccess: @escaping(RestoreVCResponse) -> Void, onFailure: @escaping(IErrorResponse) -> Void) {
        let didAddress = UserDefaults.standard.string(forKey: "DID_address") ?? ""
        var listVC : [VCDocument] = []
        var countList: Int = 0
        let realm = try! Realm()
        let page = 1
        var listVCDB : [VCDocument] = []
        bodyBuilder(json: JSON([]), string: didAddress, key: self.keyManager, context: context, onSuccess: {(body, header) in
            
            let url = String(format: "%@/api/wallet/%@/vcs?page=\(page)", self.baseURL,didAddress)
            self.request(url: url, method: HTTPMethod.get, parameters: nil, headers: header, onSuccess: {response in
                print("DataResponse :\(response)")
                
                let baseRestore = Restore(data: response)
                var maxPage = Double(baseRestore.total)/Double(baseRestore.limit)
                var listRestore: [RestoreItem] = []
                var verifiedHolderDocumentCount:Int = 0
                var verifiedIssuerDocumentCount:Int = 0
                var holderDocumentCount:Int = 0
                var issuerDocumentCount:Int = 0
                
                for item in baseRestore.items{
                    listRestore.append(item)
                }
                
                if(maxPage > 1){
                    if(Double(Int(maxPage)).isLess(than: maxPage)){
                        print("less maxPage")
                        maxPage += 1
                    }
                    for i in 2...Int(maxPage){
                        let urlMaxPage = String(format: "%@/api/wallet/%@/vcs?page=\(i)", self.baseURL,didAddress)
                        self.request(url: urlMaxPage, method: HTTPMethod.get, parameters: nil, headers: header) { responseIn in
                            print("Data ResponsePage \(i) : \(response)")
                            let resIn = Restore(data: responseIn)
                            for itemIn in resIn.items{
                                listRestore.append(itemIn)
                            }
                        } onFailure: { errorResponse in
                            print("Data ResponsePageError \(i)")
                        }
                    }
                }else{
                    let responseRestore = RestoreVCResponse(verifyHolderCount: 0, holderCount: 0, verifyIssuerCount: 0, issuerCount: 0)
                    onSuccess(responseRestore)
                }
                
                for itemRestore in listRestore {
                    countList += 1
                    if itemRestore.issuer == didAddress {
                        issuerDocumentCount += 1
                        self.verifyVC(jwt: itemRestore.jwt, onSuccess: { r in
                            if r["verification_result"] == true {
                                //build SignedDocument Model
                                var jwt: String = ""
                                let segments = itemRestore.jwt.components(separatedBy: ".")
                                if(segments.count > 0){
                                    jwt = "\(segments[1]).\(segments[2])"
                                }else{
                                    jwt = itemRestore.jwt
                                }
                                
                                let document = NotificationDocument()
                                document.title = ""
                                document.body = ""
                                document.message = jwt
                                document.creator = ""
                                document.approveEndpoint = ""
                                document.rejectEndpoint = ""
                                
                                document.created = Date()
                                document.readStatus = false
                                if r["status"] == "revoke"{
                                    document.signingStatus = "REVOKED"
                                }
                                else {
                                    document.signingStatus = "APPROVED"
                                }
                                document.id = UUID().uuidString
                                
                                SignedDocument.add(notificationDoc: document, jwt: itemRestore.jwt)
                                verifiedIssuerDocumentCount = verifiedIssuerDocumentCount + 1
                                
                            }
                            if listRestore.count == countList {
                                let responseRestore = RestoreVCResponse(verifyHolderCount: verifiedHolderDocumentCount, holderCount: holderDocumentCount, verifyIssuerCount: verifiedIssuerDocumentCount, issuerCount: issuerDocumentCount)
                                onSuccess(responseRestore)
                            }
                        }, onFailure: { error in
                            
                        })
                        
                        
                        
                    }
                    if itemRestore.holder == didAddress {
                        holderDocumentCount += 1
                        self.verifyVC(jwt: itemRestore.jwt, onSuccess: { r in
                            if r["verification_result"] == true {

                                
                                let jwtManager = JWTManager()
                                let dataCredential = jwtManager.getCredentialSchemaFromJWT(jwt: itemRestore.jwt)
                                
                                let decoder = JSONDecoder()
                                let model = try! decoder.decode(CredentialVC.self, from:dataCredential.rawData())
                                let jsonEncoder = JSONEncoder()
                                let credentialData = try! jsonEncoder.encode(model)
                                let jsonCredential = String(data: credentialData, encoding: String.Encoding.utf8)
                                
                                let vCid = r["cid"].stringValue
                                let vStatus = r["status"].stringValue
                                let vDate = r["issuance_date"].stringValue
                                let vType = r["type"].arrayValue
                                let vTags = r["tags"].stringValue
                                var listType: [String] = []
                                for vlist in vType {
                                    listType.append(vlist.rawValue as! String)
                                }
                                
                                let vExp = r["exp"].stringValue
                                let vIssuer = r["issuer"].stringValue
                                let vHolder = r["holder"].stringValue
                                
                                let vcDocument = VCDocument()
                                vcDocument.cid = vCid
                                vcDocument.status = vStatus
                                vcDocument.issuanceDate = vDate
                                vcDocument.expirationDate = vExp
                                vcDocument.type = listType.last!
                                vcDocument.issuer = vIssuer
                                vcDocument.holder = vHolder
                                vcDocument.credentialSubject = jsonCredential!
                                vcDocument.jwt = itemRestore.jwt
                                vcDocument.tags = vTags
                                vcDocument.backupStatus = true
                                
                                listVC.append(vcDocument)
                                
                                let vcDoc = realm.objects(VCDocument.self)
                                let vcDocByCid = vcDoc.filter("cid = %@", vCid)
                                for vc in vcDocByCid{
                                    listVCDB.append(vc)
                                    break
                                }
                                
                                if(listVCDB.isEmpty){
                                    
                                    realm.beginWrite()
                                    realm.add(vcDocument)
                                    try! realm.commitWrite()
                                }
                                verifiedHolderDocumentCount = verifiedHolderDocumentCount + 1
                                
                            }
                            if listRestore.count == countList {
                                let responseRestore = RestoreVCResponse(verifyHolderCount: verifiedHolderDocumentCount, holderCount: holderDocumentCount, verifyIssuerCount: verifiedIssuerDocumentCount, issuerCount: issuerDocumentCount)
                                onSuccess(responseRestore)
                            }
                        }, onFailure: { error in
                            
                        })
                      
                    }
                    
                    
                }
                
                
                
            }, onFailure: {error in
                print("error restore :\(error.message)")
                onFailure(error)
            })
        }, onFailure: { error in
            onFailure(error)
        })
    }
    
    func checkExistingVCinBackupWallet(cid: String, context: LAContext, onSuccess: @escaping(JSON) -> Void, onFailure: @escaping(IErrorResponse) -> Void) {
        let didAddress = UserDefaults.standard.string(forKey: "DID_address") ?? ""
        bodyBuilder(json: JSON([]), string: didAddress, key: self.keyManager, context: context) { (body, header) in
            let url = String(format: "%@/api/wallet/%@/vcs/%@", self.baseURL, didAddress, cid)
            self.request(url: url, method: HTTPMethod.get, parameters: nil, headers: header, onSuccess: {response in
                onSuccess(response)
            }, onFailure: { errorResponse in
                onFailure(errorResponse)
            })
        } onFailure: { error in
            onFailure(error)
        }
    }
    func getVCStatusList(cids: String, onSuccess: @escaping(JSON) -> Void, onFailure: @escaping(IErrorResponse) -> Void){
    
        let url = String(format: "%@/vc/status?cid=%@", self.baseURL, cids)
        self.request(url: url, method: HTTPMethod.get, parameters: nil, onSuccess: { response in
            onSuccess(response)
                        
        }, onFailure: { error in
            onFailure(error)
        })
    }
    
    func getVCStatus(cid: String, onSuccess: @escaping(JSON) -> Void, onFailure: @escaping(IErrorResponse) -> Void){
        let url = String(format: "%@/vc/status/%@", self.baseURL, cid)
        self.request(url: url, method: HTTPMethod.get, parameters: nil, onSuccess: { response in
            onSuccess(response)
                        
        }, onFailure: { error in
            onFailure(error)
        })
    }
    
//    private func JWTAuthHeader(type: String?,kid:String?) -> JSON{
//
//        return JSON([
//            "alg": "ES256",
//            "typ": type ?? "typ",
//            "kid": kid
//        ])
//    }
//
//    private func JWTPayLoad() -> JSON{
//        JSONSerialization.jsonObject(with: <#T##Data#>, options: <#T##JSONSerialization.ReadingOptions#>)
//
//        return JSON([
//            "jti": jti,
//            "iss": iss,
//            "nbf": nbf,
//            "sub": sub,
//            "vp": vp,
//            "vc": vc,
//            "nonce": nonce,
//            "exp": exp
//        ])
//    }
}

struct RestoreVCResponse : Codable {
    var verifyHolderCount: Int = 0
    var holderCount: Int = 0
    var verifyIssuerCount: Int = 0
    var issuerCount: Int = 0
}

class Restore {
    var _data:JSON
    
    init(data:JSON){
        _data = data
    }
    
    open var page : Int{
        return _data["page"].intValue
    }
    
    open var total : Int{
        return _data["total"].intValue
    }
    
    open var limit : Int{
        return _data["limit"].intValue
    }
    
    open var count : Int{
        return _data["count"].intValue
    }
    
    open var items : [RestoreItem]{
        var restoreItemList: [RestoreItem] = []
        let itemArray = _data["items"].arrayValue
        for item in itemArray {
            let itemRestore = RestoreItem(id: item["id"].stringValue, cid: item["cid"].stringValue, schemaType: item["schema_type"].stringValue, issuanceDate: item["issuance_date"].stringValue, jwt: item["jwt"].stringValue, issuer: item["issuer"].stringValue, holder: item["holder"].stringValue, status: item["status"].stringValue)
            restoreItemList.append(itemRestore)
        }
        
        return restoreItemList
    }
}

class RestoreItem {
    var id : String
    var cid : String
    var schemaType : String
    var issuanceDate : String
    var jwt : String
    var issuer : String
    var holder : String
    var status : String
    
    init(id:String, cid:String, schemaType:String, issuanceDate: String, jwt: String, issuer:String, holder:String, status:String){
        self.id = id
        self.cid = cid
        self.schemaType = schemaType
        self.issuanceDate = issuanceDate
        self.jwt = jwt
        self.issuer = issuer
        self.holder = holder
        self.status = status
    }
}



struct JWTAuthHeader: Encodable {
    var alg:String = "ES256"
    var typ:String = "๋JWT"
    var kid:String
}

struct JWTPayLoadVP : Encodable{
    var jti: String
    var aud: String
    var iss: String
    var nbf: Int64
    var vp: JWTVCDoc
}

//struct JWTPayLoadVC : Decodable{
//    var jti: String
//    var iss: String
//    var nbf: Int
//    var sub: String
//    var vc: Any
//}

struct JWTPayLoadDetail : Codable{
    var jti: String
    var aud: String
    var iss: String
    var nbf: Int
    var vp: JWTVCDoc
}

struct JWTVCDoc : Codable {
    var context : String = "https://www.w3.org/2018/credentials/v1"
    var type : [String] = ["claimPresentation","VerifiablePresentation"]
    var verifiableCredential : [String]
    
    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case type
        case verifiableCredential
    }
}

extension String {
    func removeWhitespaces() -> String? {
        let range = NSRange(location: 0, length: self.count)
        guard let regex = try? NSRegularExpression(pattern: "\\s(?=(([^\"]*\"[^\"]*){2})*$)") else {
            return nil
        }
        print("CheckData : \(self)")
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
    }
    
    func base64Encoded(shouldRemoveWhitespaces: Bool = false) -> String? {
        if shouldRemoveWhitespaces {
            return removeWhitespaces()?.base64Encoded()
        }

        return data(using: .utf8)?.base64EncodedString()
    }

    func sanitizeBase64Padding() -> String {
        return self.padding(
            toLength: ((self.count+3)/4)*4,
            withPad: "=",
            startingAt: 0
        )
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self.sanitizeBase64Padding()) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
 
extension Int64 {
    func toISOFormat() -> String{
        let timeInterval = TimeInterval(self)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatterGet.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatterGet.string(from: date)
    }
}

