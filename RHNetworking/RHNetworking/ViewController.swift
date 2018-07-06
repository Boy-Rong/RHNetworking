//
//  ViewController.swift
//  RHNetworking
//
//  Created by 荣恒 on 2018/6/28.
//  Copyright © 2018 荣恒. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        testData()
        
    }

    /// 使用方法
    func testData()  {
        let provider = RHNetworkProvider<GitHub>()
        
        // 请求1, 使用测试数据
        provider.request(GitHub.userProfile("495929699")) { (result) in
            if result.isSuccess {
                print("成功：\(result.value!)")
            } else {
                print("失败：\(result.error!)")
            }
        }
        
        // 请求2，使用真实数据，但是github返回的格式不是常规的 message code data 格式。
        /// 所以结果为错误
        provider.request(GitHub.userRepositories("495929699")) { (result) in
            if result.isSuccess {
                print("成功：\(result.value!)")
            } else {
                print("失败：\(result.error!)")
            }
        }
        
        /// 请求3，使用响应式请求。可以自己扩展RxSwift
        provider.reactiveRequest(GitHub.userRepositories("495929699"))
    }


}


enum GitHub {
    case userProfile(String)    //请求profile
    case userRepositories(String)       //请求repository
}

extension GitHub : RHApiType {
    var baseURL: String {
        return "https://api.github.com"
    }
    
    var path: String {
        switch self {
        case .userProfile(let name):
            return "/users/\(name)"
        case .userRepositories(let name):
            return "/users/\(name)/repos"
        }
    }
    
    var parameters: [String : Any] {
        switch self {
        case .userRepositories:
            return ["sort": "pushed"]
        case .userProfile:
            return [:]
        }
    }
    
    var method: Method {
        return .get
    }
    
    var testData: RHResponse.DataType? {
        switch self {
        case .userProfile:
            return [["login" : "495929699","url" : "https://api.github.com/users/495929699"]]
        case .userRepositories:
//            return [["name" : "RHNetworking","full_name" : "495929699/RHNetworking"]]
            return nil
        }
    }
    
    
}
