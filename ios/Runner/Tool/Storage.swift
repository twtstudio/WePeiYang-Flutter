//
//  Storage.swift
//  Runner
//
//  Created by Zr埋 on 2022/9/6.
//

struct Storage {
    static let defaults = UserDefaults(suiteName: "group.com.wepeiyang")!
    
    static func removeAll() {
        UserDefaults.standard.removePersistentDomain(forName: "group.com.wepeiyang")
    }
    
    static let flutter = UserDefaults.standard
    
    // 用户选择是否开启推送
    static let canPushKey = "flutter.can_push"
    
    
}
