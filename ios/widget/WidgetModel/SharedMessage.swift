//
//  SharedMessage.swift
//  SharedMessage
//
//  Created by 李佳林 on 2022/9/18.
//

import SwiftUI

class SharedMessage: ObservableObject {
    // 数据存储
    static let useravatarKey: String = "useravatarKey"
    static let usernameKey: String = "usernameKey"
    static let isNightModeKey: String = "isNightModeKey"
    static let semesterStartAtKey: String = "semesterStartAtKey"
    static let semesterNameKey: String = "semesterNameKey"
    
    
    static var username: String {Storage.defaults.string(forKey: usernameKey) ?? ""}
    static var useravatar: String {Storage.defaults.string(forKey: useravatarKey) ?? ""}
    static var isNightMode: Bool { Storage.defaults.bool(forKey: isNightModeKey)}
    static var semesterStartAt: String { Storage.defaults.string(forKey: semesterStartAtKey) ?? ""}
    static var semesterName: String { Storage.defaults.string(forKey: semesterNameKey) ?? ""}
    
    
    ///清缓存
    static func remove(_ key: String) { Storage.defaults.removeObject(forKey: key) }
    
    
    /// 清空全部的缓存
    static func removeAll() {
        remove(usernameKey)
        remove(useravatarKey)
        remove(isNightModeKey)
        remove(semesterStartAtKey)
    }
    
}
