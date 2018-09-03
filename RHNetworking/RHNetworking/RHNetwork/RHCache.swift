//
//  RHCache.swift
//  RHNetworking
//
//  Created by 荣恒 on 2018/9/3.
//  Copyright © 2018年 荣恒. All rights reserved.
//

import Foundation

// 网络缓存类，利用三方库Cache
class RHCache {
    
    static let cache = RHCache()
    
    private init() {
        
    }
    
    /// 异步设置缓存
    func asynSet(object : Any ,key : String) {
        
    }

    ///异步获取缓存
    func asynObject(with key : String, block : ((Any?) -> Void)) {
        block(nil)
    }
    
    /// 同步获取数据
    func synObject(with key : String) -> Any? {
        return nil
    }
    
}

extension RHCache {
    
    func key(with api : RHApiType) -> String {
        return ""
    }
    
}








