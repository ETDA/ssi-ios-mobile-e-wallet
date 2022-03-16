//
//  JWTManager.swift
//  ETDASSI
//
//  Created by Manuchet Rungraksa on 26/8/2564 BE.
//

import Foundation
import SwiftyJSON

class JWTManager {
    
    static var shared = JWTManager()
    
    let testJWT = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjM2ZmI4MzRlMTdiNGVjYjU3NTNhZWM3OTgwMjkxZjg3OTNiMjY5MzZiY2IzMzAxMmQ5MDBmNmYxY2YwMjljMWEifQ.eyJAY29udGV4dCI6Imh0dHBzOi8vd3d3LnczLm9yZy8yMDE4L2NyZWRlbnRpYWxzL3YxIiwiaWQiOiJiNDllYzAyMGQ1MDgyYWNkODJkMDI2YWIwNDEzYzM0MjVhYjQ5NTdiMjMxYWUzMjc2ZTUzMDA5NzVhNDYwNzdjIiwidHlwZSI6WyJWZXJpZmlhYmxlQ3JlZGVudGlhbCIsIk1lZGljYWxDZXJ0aWZpY2F0ZUNyZWRlbnRpYWwiXSwiaXNzdWVyIjoiZGlkOmlkaW46ZWIzZTQyM2I2MDg3YzAwYjhhMjZkODZhNTMwZjAxMzAyMzBiZWE5NTkxNDgzYTcyM2NjY2VlNTI2ZTg5MmI0YSIsImlzc3VhbmNlRGF0ZSI6IjIwMjEtMDgtMjBUMDg6MDk6NTIuMTE3WiIsImV4cGlyYXRpb25EYXRlIjoiMjAyMi0wOC0yMFQwODowOTo1Mi4xMTdaIiwiY3JlZGVudGlhbFNjaGVtYSI6eyJpZCI6Imh0dHBzOi8vc3NpLXRlc3QudGVkYS50aC9hcGkvc2NoZW1hcy9hODM4M2I4My1iMjU2LTQzMTAtYTYyYy1mNWRhMDMzYmQzZmQvMS4wLjIvc2NoZW1hIiwidHlwZSI6Ikpzb25TY2hlbWFWYWxpZGF0b3IyMDE4In0sImNyZWRlbnRpYWxTdWJqZWN0Ijp7IuC4iuC4t-C5iOC4reC5guC4o-C4h-C4nuC4ouC4suC4muC4suC4pSI6IuC5guC4o-C4h-C4nuC4muC4suC4muC4suC4peC4geC4o-C4uOC4h-C4qOC4o-C4tSIsIuC5gOC4muC4reC4o-C5jOC4leC4tOC4lOC4leC5iOC4rSI6IjA4OS0wMzQ0NTAzMiIsIkRvY3RvciI6eyLguIrguLfguYjguK3guYHguJ7guJfguKLguYwiOiLguJfguKfguLXguKjguLHguIHguJTguLTguYwg4LiK4Li54Lib4Li1Iiwi4Lij4Lir4Lix4LiqIjoiRE9DVE9SMjM0NTQzIiwi4LmA4LiJ4Lie4Liy4Liw4LiX4Liy4LiH4Lie4Li04LmA4Lio4LipIjoi4LiI4Lih4Li54LiBLCDguJXguLIsIOC4hOC4rSJ9LCJQYXRpZW50IEluZm9ybWF0aW9uIjp7Im5hbWUiOiLguKHguLDguKXguLQg4Lin4Li04LiI4Li04LiV4Lij4LiB4Li44LilIiwiZGF0ZU9mQmlydGgiOiIxOTg3LTExLTI1VDA4OjA5OjUyLjExN1oiLCJhZ2UiOiIzNCJ9LCJEaWFnbm9zdGljcyI6eyLguYLguKPguIQiOiLguYTguIvguJnguLHguKrguK3guLHguIHguYDguKrguJoiLCLguK3guLLguIHguLLguKMiOiLguITguLHguJTguIjguKHguLnguIEiLCJEcnVncyI6W3si4LiK4Li34LmI4Lit4Lii4LiyIjoi4Lie4Liy4Lij4Liy4LmA4LiL4LiV4Liy4Lih4Lit4LilIiwi4Lij4Liy4Lii4Lil4Liw4LmA4Lit4Li14Lii4LiU4Lii4LiyOiI6IuC5geC4geC5ieC4m-C4p-C4lCJ9XSwiRHJ1Z3NJbmZvcm1hdGlvbiI6W3si4Liq4LmI4Lin4LiZ4Lib4Lij4Liw4LiB4Lit4Lia4Lii4LiyIjp7IkRydWcgTmFtZToiOiJQYXJhY2V0YW1vbCIsIkltcG9ydERldGFpbCI6W3si4LiK4Li34LmI4Lit4Lia4Lij4Li04Lip4Lix4LiXIjoi4Lia4Lij4Li04Lip4Lix4LiXIOC4nuC4suC4o-C4suC5gOC4i-C4leC4suC4oeC4reC4pSIsIuC4p-C4seC4meC4l-C4teC5iCI6IjIwMjEtMDgtMTNUMDg6MDk6NTIuMTE3WiIsIk1vcmUiOnsiRGV0YWlsIjoiS2VlcCBpbiAyNSBkZWdyZWUifX1dfX1dfSwi4LiE4Lin4Lij4Lit4LiZ4Li44LiN4Liy4LiV4LmD4Lir4LmJIjoi4Lil4Liy4Lir4Lii4Li44LiU4LiH4Liy4LiZIiwi4LiV4Lix4LmJ4LiH4LmB4LiV4LmI4Lin4Lix4LiZ4LiX4Li14LmIIjoiMjAyMS0wOC0wMVQwODowOTo1Mi4xMTdaIiwi4LiW4Li24LiH4Lin4Lix4LiZ4LiX4Li14LmIIjoiMjAyMS0wOC0wMlQwODowOTo1Mi4xMTdaIn0sInByb29mIjp7ImlkIjoiODJhMWEzZmRkN2IyNWE0MjY5YjI0NDYyODEwZDBlMjI1NTE3ZTY0M2I4YmM3MjE1Y2I1NWNmNWVkYjcyYjAxMiIsInR5cGUiOiJFY2RzYVNlY3AyNTZyMVNpZ25hdHVyZTIwMTkiLCJjcmVhdGVkIjoiMjAyMS0wOC0yNFQwODowOTo1Mi4xMTdaIiwiandzIjoiIn0sImlhdCI6MTYyOTc4NjAzM30.MEUCIQCFdDjU/G6svyD08IPr4y0jltBIYVGOnz9/rN9AIJsjbgIgKHJ08MDCK3Y1b/lg+kPa8hZlObRsu6+XQau3Twwa9uU="
    
    func getCredentialSchemaFromJWT(jwt: String) -> JSON {
        let payload = decode(jwtToken: jwt)
        
        let json = JSON(payload)
        return json
    }
    
    func getHeaderFromJWT(jwt: String) -> JSON{
        let payload = decodeHead(jwtToken: jwt)
        let json = JSON(payload)
        return json
    }

    func decodeHead(jwtToken jwt: String) -> [String: Any] {
        let segments = jwt.components(separatedBy: ".")
        if(segments.count >= 0){
            return decodeJWTPart(segments[0]) ?? [:]
        }else{
            return [:]
        }
    }
    
    func decode(jwtToken jwt: String) -> [String: Any] {
        let segments = jwt.components(separatedBy: ".")
        if(segments.count > 0){
            return decodeJWTPart(segments[1]) ?? [:]
        }else{
            return [:]
        }
    }
    
    func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
    
    func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
            return nil
        }
        
        return payload
    }
}

struct CredentialVC : Codable{
    var iss: String
    var jti: String
    var vc: CredentialVCDetail
}

struct CredentialVCDetail : Codable {
    var context : [String]
    var type: [String]
    var credentialSchema : CredentialSchema
    var credentialSubject : CredentialSubject
    
    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case type
        case credentialSchema
        case credentialSubject
    }
}

struct CredentialSchema : Codable {
    var id : String
    var type : String
}

struct CredentialSubject : Codable {
//    var String : String
}

//class CredentialVC {
//    var _data : JSON
    
//    init(data:JSON) {
//        _data = data
//    }
    
//    open var vc : CredentialVCDetail{
//        return CredentialVCDetail(data: _data["vc"])
//    }
//
//    open var issuer : String{
//        return _data["iss"].stringValue
//    }
//
//    open var id : String{
//        return _data["jti"].stringValue
//    }
//}

//class CredentialVCDetail{
//    var _data : JSON
//    init(data:JSON){
//        _data = data
//    }
//    open var listType : [String]{
//        return _data["type"].rawValue as! [String]
//    }
//    open var credentialSchema : CredentialVCDetailSchema{
//        let dataSchema = _data["credentialSchema"]
//        return CredentialVCDetailSchema(id: dataSchema["id"].stringValue, type: dataSchema["type"].stringValue)
//    }
//    open var credentialSubject : CredentialSubject{
//        let dataSub = _data["credentialSubject"]
//        return CredentialSubject(stringSub: dataSub["String"].stringValue)
//    }
//}

//class CredentialVCDetailSchema{
//    var id : String?
//    var type : String?
//    init(id:String,type:String) {
//        self.id = id
//        self.type = type
//    }
//
//}
//
//class CredentialSubject{
//    var stringSub : String?
//
//    init(stringSub : String) {
//        self.stringSub = stringSub
//    }
//}
