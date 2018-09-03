//
//  RHNetworkReachability.swift
//  YN_New
//
//  Created by 荣恒 on 2018/1/10.
//  Copyright © 2018年 荣恒. All rights reserved.
//

import Foundation
import Alamofire

enum RHNetworkStatus : String {
    case Not = "没网"
    case WIFI = "WIFI"
    case Unknown = "未知网络"
    case WWAN = "移动网络"
}

extension Notification.Name {
    /// 网络状态改变
    static let RHNetworkStatus = Notification.Name(rawValue: "RHNetworkStatusChange")
}

/// 全局网络类
class AppNetwork {
    
    /// 网络状态管理者
    fileprivate static let reachability = NetworkReachabilityManager()!
    
    /// 全局网络状态,默认为WIFI
    static var networkState : RHNetworkStatus = .WIFI {
        didSet {
            let info = ["status" : networkState]
            /// 发送通知
            NotificationCenter.default
                .post(name: NSNotification.Name.RHNetworkStatus,
                      object: nil, userInfo: info)
        }
    }
    
    static var isWIFI : Bool {
        return reachability.isReachableOnEthernetOrWiFi
    }
    
    /// 是否有网
    static var isNetwork : Bool {
        return reachability.isReachable
    }
    
    /// 全局监听
    static func startListening() {
        
        reachability.startListening()
        /// 监听
        reachability.listener = { status in
            
            if reachability.isReachable {
                switch status {
                case .notReachable : networkState = .Not
                case .unknown : networkState = .Unknown
                case .reachable(.ethernetOrWiFi) : networkState = .WIFI
                case .reachable(.wwan) : networkState = .WWAN
                }
                
            } else {
                networkState = .Not
            }
        }
    }
    
    /// 停止监听
    static func stopListening() {
        reachability.stopListening()
    }
    
    
}
