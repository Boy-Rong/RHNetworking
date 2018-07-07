//
//  RHNetworkProvider.swift
//  SwiftBaseProject
//
//  Created by 荣恒 on 2017/12/25.
//  Copyright © 2017年 荣恒. All rights reserved.
//

import Foundation

import Alamofire


protocol RHNetworkProviderType : class {
    associatedtype API : RHApiType
    
    @discardableResult
    func request(_ api : API, completion: @escaping (RHResult<RHResponse.DataType>) -> Void) -> DataRequest?
    
    @discardableResult
    func requestData(_ api : API,  completion: @escaping (RHResult<Data>) -> Void) -> DataRequest?
}
extension RHNetworkProviderType { }


/// 请求类，赋值调度
class RHNetworkProvider<API : RHApiType> : RHNetworkProviderType {

    let manager : Manager
    
    /// 正在请求的任务
    private(set) var taskQueue : [DataRequest] = []
    
    init(_ manager : Manager = Manager.default) {
        self.manager = manager
    }

    
    /// 创建DataRequest
    private func createRequest(_ api : API) -> DataRequest {
        /// 获取默认请求头
        var header = Manager.defaultHTTPHeaders
        /// 添加额外请求头
        if !api.header.isEmpty {
            for value in api.header {
                header.updateValue(value.value, forKey: value.key)
            }
        }
        
        return manager.request(api.requestURL, method: api.method,
                               parameters: api.parameters, encoding: api.parameterEncoding,
                               headers: header)
    }
    
}

// MARK: - 实现请求的根方法
extension RHNetworkProvider  {
    
    /// 请求JSON
    func request(_ api : API,  completion: @escaping (RHResult<RHResponse.DataType>) -> Void) -> DataRequest? {
        
        /// 测试数据
        if let test = api.testData {
            completion(.Success(test))
            return nil
        }
        
        /// 没有网络时直接返回错误
        if AppNetwork.networkState == .Not {
            completion(.Failure(RHError("网络连接已断开！")))
            return nil
        }
        
        let dataRequest = createRequest(api)
        
        //此任务正在进行
        if let index = taskQueue.index(of: dataRequest) {
            if !api.allowRepeat {
                return self.taskQueue[index]
            }
        }
        /// 加入到任务队列
        taskQueue.append(dataRequest)
        
        dataRequest.responseJSON { (dataResponse) in
            let result = dataResponse.result
            
            if result.isSuccess {  //请求成功
                let json = result.value ?? [:]  //容错处理，SB后台不返回数据时的为空字典
                let response = RHResponse(json) // 解析返回的数据
                
                if response.code == .Success {   //成功响应
                    completion(.Success(response.data))
                    
                } else {
                    completion(.Failure(RHError("响应错误")))
                }
                
            } else {
                completion(.Failure(result.error!))
            }
            
            /// 从任务队列中删除
            if let index = self.taskQueue.index(of: dataRequest) {
                self.taskQueue.remove(at: index)
            }
        }
        return dataRequest
    }
    
    /// 请求Data
    func requestData(_ api : API,  completion: @escaping (RHResult<Data>) -> Void ) -> DataRequest? {
        
        /// 没有网络时直接返回错误
        if AppNetwork.networkState == .Not {
            completion(.Failure(RHError("网络连接已断开！")))
            return nil
        }
        
        let dataRequest = createRequest(api)
        //此任务正在进行
        if let index = taskQueue.index(of: dataRequest) {
            if !api.allowRepeat {
                return taskQueue[index]
            }
        }
        taskQueue.append(dataRequest)
        
        dataRequest.responseData { (response) in
            let result = response.result
            if result.isSuccess {
                completion(.Success(result.value ?? Data()))
                
            } else {
                completion(.Failure(result.error!))
            }
            
            /// 从任务队列中删除
            if let index = self.taskQueue.index(of: dataRequest) {
                self.taskQueue.remove(at: index)
            }
        }
        
        return dataRequest
    }
    
}



// MARK: - 判断请求是否一样
extension Alamofire.DataRequest : Equatable {
    ///更具请求的URL是否一样 判断是否相等
    public static func ==(lhs: Alamofire.DataRequest, rhs: Alamofire.DataRequest) -> Bool {
        /// 请求方式相同
        if lhs.request?.httpMethod == rhs.request?.httpMethod {
            /// URL相同
            if lhs.request?.url?.absoluteString == rhs.request?.url?.absoluteString {
                /// 如果是get请求则URL相等就可以，若是其他请求方式则要求请求体相同
                if lhs.request?.httpMethod == "GET" ||
                    lhs.request?.httpBody == rhs.request?.httpBody {
                    return true
                }
            }
        }
        return  false
    }
    
}





