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
    
    func reactiveRequest(_ api : API) -> SignalProducer<RHResponse.DataType,RHError> {
        
        return SignalProducer{ [weak self] observer, lifetime in
            let dataRequest = self?.request(api, completion: { (result) in
                if result.isSuccess {
                    observer.send(value: result.value!)
                } else {
                    let error = RHError(result.error!)
                    observer.send(error:error)
                }
                
                observer.sendCompleted()
            })
            
            lifetime.observeEnded {
                dataRequest?.cancel()
            }
        }
    }
    
    func reactiveRequestData(_ api : API) -> SignalProducer<Data,RHError> {
        
        return SignalProducer { [weak self] observer, lifetime in
            let dataRequest = self?.requestData(api, completion: { (result) in
                if result.isSuccess {
                    observer.send(value: result.value!)
                } else {
                    let error = RHError(result.error!)
                    observer.send(error:error)
                }
                
                observer.sendCompleted()
            })
            
            lifetime.observeEnded {
                dataRequest?.cancel()
            }
        }
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

// MARK: - 未返回类型为 [[String : Any]] 添加信号映射
extension SignalProducer where Value == [[String : Any]] {
    
    func map<T : Mappable>(to : T.Type) -> SignalProducer<T,RHError> {
        return mapError({ RHError($0) }).flatMap(.latest, { (value) in
            return SignalProducer<T,RHError>({ (observer, lifetime) in
                if let data = value.first,
                    let object = T(JSON: data) {
                    observer.send(value: object)
                } else {
                    observer.send(error: RHError("转模型错误"))
                }
            })
        })
    }
    
    func mapArray<T : Mappable>(to : T.Type) -> SignalProducer<[T],RHError> {
        return mapError({ RHError($0) })
            .flatMap(.latest, { (value) in
                return SignalProducer<[T],RHError>({ (observer, lifetime) in
                    if let data = value.first,
                        let _ = data.first {
                        observer.send(value: Mapper<T>().mapArray(JSONArray: value))
                    } else {
                        observer.send(error:RHError("转模型错误"))
                    }
                })
            })
    }
    
}











