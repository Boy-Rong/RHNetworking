//
//  RHCache.swift
//  RHNetworking
//
//  Created by 荣恒 on 2018/9/3.
//  Copyright © 2018年 荣恒. All rights reserved.
//

import Foundation
import YYCache

fileprivate let cacheName = "RHNetworkCache"

// 网络缓存类，利用三方库Cache
class RHCache {
    
    static let `default` = RHCache()
    
//    /// 30M
//    let diskCacheSize : UInt = 1024 * 20
//    /// 2天
//    let diskCacheTime : UInt = 2 * 12 * 3600
    
    let cache : YYCache
    
    private init() {
        cache = YYCache(name: cacheName)!
        /// 最大缓存条数
        cache.memoryCache.countLimit = 100
        /// 磁盘缓存大小
        cache.diskCache.costLimit = 30 * 1024
    }
    
    /// 异步设置缓存
    func asyncSet(object : Any ,key : String) {
        cache.setObject(object as? NSCoding, forKey: key, with: nil)
    }

    ///异步获取缓存
    func asyncObject(with key : String, block : @escaping ((Any?) -> Void)) {
        //异步判断是否有缓存
        cache.containsObject(forKey: key) { (key, isCache) in
            if isCache {
                // 异步获取缓存
                self.cache.object(forKey: key) { (key, object) in
                    block(object)
                }
            } else {
                block(nil)
            }
        }
        
        
    }
    
    /// 删除磁盘缓存
    func removeAllCache() {
        cache.diskCache.removeAllObjects()
    }
    
}

extension RHCache {
    
    /// 计算缓存key
    func key(with api : RHApiType) -> String {
        // 字典toJson
        let data = try? JSONSerialization.data(withJSONObject: api.parameters, options: [])
        let json = String(data: data!, encoding: .utf8)
        let parametersJson = json ?? ""
        
        return api.baseURL + api.path + api.method.rawValue + parametersJson
    }
    
}








