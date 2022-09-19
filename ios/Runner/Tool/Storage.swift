//
//  Storage.swift
//  Runner
//
//  Created by Zr埋 on 2022/9/6.
//

import Foundation

/// app group名称
public let GROUP_NAME = "group.com.wepeiyang"

struct Storage {
    static let group = UserDefaults(suiteName: GROUP_NAME)!
    
    static let standard = UserDefaults.standard
    
    static func removeAll() {
        UserDefaults.standard.removePersistentDomain(forName: GROUP_NAME)
    }
    
    static let flutter = UserDefaults.standard
    
    static func saveDataToGroupStorage(data: String, in fileName: String) {
        let GroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GROUP_NAME)
        let fileURL = GroupURL?.appendingPathComponent("widgetdata-\(fileName).data")
        FileManager.default.createFile(atPath: fileURL!.path, contents: data.data(using: .utf8))
    }
    
    static func getDataFromGroupStorage(key: String) -> String {
        let GroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GROUP_NAME)
        let fileURL = GroupURL?.appendingPathComponent("widgetdata-\(key).data")
        
        let data = try? String(contentsOf: fileURL!, encoding: .utf8)
        return data ?? ""
    }
}

enum StorageKey {
         // 用户选择是否开启推送
    case canPush,
         // 课表起始学期
         termStartDate,
         // 夜猫子模式
         nightMode,
         // 课表数据
         courseData
         
    var key: String {
        switch self {
        case .canPush:
            return "can_push"
        case .termStartDate:
            return "termStartDate"
        case .nightMode:
            return "nightMode"
        case .courseData:
            return "courseData"
        }
    }
    
    func getStandardData() -> String {
        let prefix = "flutter."
        return Storage.standard.string(forKey: prefix + self.key) ?? ""
    }
    
    func getGroupData() -> String {
        return Storage.getDataFromGroupStorage(key: self.key)
    }
    
    static func saveToGroupStorage() {
        let types: [StorageKey] = [.termStartDate, .nightMode, .courseData]
        for type in types {
            let data = type.getStandardData()
            Storage.saveDataToGroupStorage(data: data, in: type.key)
        }
    }
}

protocol Storable {
    init()
}

class Store<T: Codable & Storable>: ObservableObject {
    @Published var object: T
    @Published var storageKey: StorageKey

    init(_ storageKey: StorageKey) {
        self.object = T()
        self.storageKey = storageKey
        load()
    }

    func load() {
        if(storageKey.getGroupData() != ""){
            guard let object = try? JSONDecoder().decode(T.self, from: storageKey.getGroupData().data(using: .utf8)!) else {
                return
            }
            self.object = object
        }  else {
            print(storageKey.getGroupData())
            print("json 解码失败")
        }
    }

    func remove() {
        self.object = T()
    }
}

struct SwiftStorage {

    static let courseTable = Store<CourseTable>(StorageKey.courseData)

    static func removeAll() {
        UserDefaults.standard.removePersistentDomain(forName: "group.com.wepeiyang")
    }

}
