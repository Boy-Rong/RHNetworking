//
//  RHNetworkExtensions.swift
//  SwiftBaseProject
//
//  Created by 荣恒 on 2017/12/25.
//  Copyright © 2017年 荣恒. All rights reserved.
//

import Foundation

import Alamofire
import ReactiveSwift
import Result
import ObjectMapper


// MARK: - 扩展 （扩展的方法依赖根请求方法，默认实现根方法，保证灵活性）
extension RHNetworkProviderType {
    
    func reactiveRequest(_ api : API) -> SignalProducer<RHResult<RHResponse.DataType>,NoError> {
        
        return SignalProducer{ [weak self] observer, lifetime in
            let dataRequest = self?.request(api, completion: { (result) in
                
                observer.send(value: result)
                observer.sendCompleted()
            })
            
            lifetime.observeEnded {
                dataRequest?.cancel()
            }
        }
    }
    
    func reactiveRequestData(_ api : API) -> SignalProducer<RHResult<Data>,NoError> {
        
        return SignalProducer { [weak self] observer, lifetime in
            let dataRequest = self?.requestData(api, completion: { (result) in
                
                observer.send(value: result)
                observer.sendCompleted()
            })
            
            lifetime.observeEnded {
                dataRequest?.cancel()
            }
        }
    }
}


// MARK: - Reactive 扩展
extension RHNetworkProvider : ReactiveExtensionsProvider {}

extension Reactive where Base : RHNetworkProviderType {
    
    func request(_ api : Base.API) -> SignalProducer<RHResult<RHResponse.DataType>,NoError> {
        return base.reactiveRequest(api)
    }
    
    func requestData(_ api : Base.API) -> SignalProducer<RHResult<Data>,NoError> {
        return base.reactiveRequestData(api)
    }
}


// MARK: - 当响应结果扩展（字典转模型映射）
extension RHResult where Value == Array<[String : Any]> {
    func map<T : Mappable>() -> T? {
        guard let array = value, let data = array.first
            else { return nil }
        return T(JSON: data)
    }
    
    func mapArray<T : Mappable>() -> [T] {
        guard let array = value else { return [] }
        return Mapper<T>().mapArray(JSONArray: array)
    }
    
    
    /// 更具路径转换某个字段
    func map<T : Equatable>(_ index : Int = 0, _ key: String) -> [T] {
        guard let array = value else { return [] }
        guard index < array.count else { return [] }
        
        let jsonDictionary = array[index] as NSDictionary
        guard let value = jsonDictionary.value(forKeyPath: key) as? [T] else {
            return []
        }
        
        return value
    }
    
}











