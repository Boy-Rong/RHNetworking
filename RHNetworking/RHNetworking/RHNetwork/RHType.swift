//
//  RHRequest.swift
//  SwiftBaseProject
//
//  Created by 荣恒 on 2017/12/24.
//  Copyright © 2017年 荣恒. All rights reserved.
//

import Foundation

import Alamofire


/// Alamofire 引用类型
typealias Manager = Alamofire.SessionManager
typealias Encoding = Alamofire.ParameterEncoding
typealias Method = Alamofire.HTTPMethod
typealias DataRequest = Alamofire.DataRequest



// MARK: - API基本协议
protocol RHApiType {
    
    var baseURL: String { get }
    var path: String { get }
    var method : Method { get }
    var parameters : [String: Any] { get }
    /// 需要补充的head信息
    var header : [String: String] { get }
    var parameterEncoding : Encoding { get }
    
    /// 是否允许同一请求多次发送 默认不允许
    var allowRepeat : Bool { get }
    
    /// 测试返回数据,默认为nil. 只对请求json有用
    var testData : RHResponse.DataType? { get }
}
extension RHApiType {
    /// 需要加 “/”
    var requestURL : URL { return URL(string: baseURL + path)! }
    var method : Method { return .post }
    var parameterEncoding : Encoding {
        return URLEncoding.default
    }
    var header : [String : String] {
        return [:]
    }
    
    var allowRepeat : Bool {
        return false
    }
    
    var testData : RHResponse.DataType? {
        return nil
    }
}



// MARK: - 服务器返回的结构，请求JSON时的格式
struct RHResponse {
    /// 服务器返回的 data字段 类型
    /// 类型可根据情况更改
    typealias DataType = Array<[String : Any]>
    
    let code : RHResponseStatus
    let message : String
    let data : DataType
    
    // MARK: - 网络响应状态
    enum RHResponseStatus : Int {
        case Success = 0          //请求成功
        case LoginExpired     //登录过期
        case Failure
    }
    
    init(_ json : Any) {
        if let json = json as? [String : Any],
            let code = json["code"] as? Int,
        let message = json["msg"] as? String,
        let data = json["data"] as? DataType
        {
            self.code = RHResponseStatus(rawValue: code) ?? .Failure
            self.message = message
            self.data = data
        } else {
            self.code = .Failure
            self.message = "Error"
            self.data = []
        }
    }
}



// MARK: - RH网络错误类型
struct RHError : Error {
    let message : String
    let info : [String : Any]?
    
    init(_ message : String = "Error",
         _ info : [String : Any]? = nil) {
        self.message = message
        self.info = info
    }
    
    init(_ error : Error) {
        self.message = error.localizedDescription
        self.info = nil
    }
}

// MARK: - 请求返回的结果
enum RHResult<Value> {
    case Success(Value)
    case Failure(Error)
    
    var isSuccess : Bool {
        switch self {
        case .Success :
            return true
        case .Failure :
            return false
        }
    }
        
    var value : Value? {
        switch self {
        case .Success(let value):
            return value
        case .Failure :
            return nil
        }
    }
    
    var error : Error? {
        switch self {
        case .Success :
            return nil
        case .Failure(let error) :
            return error
        }
    }
        
}









