//
//  ErrorResponse.swift
//  ETDASSI
//
//  Created by Finema on 16/6/2564 BE.
//

import Foundation

public struct ErrorResponse : IErrorResponse{
    var errorCode : UInt
    var message : String
}

protocol IErrorResponse {
    var errorCode : UInt {get}
    var message : String {get}
}
