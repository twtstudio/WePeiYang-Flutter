//
//  Storage.swift
//
//  Created by 李佳林 on 2022/9/18.
//

import Foundation

struct Storage {
    static let defaults = UserDefaults(suiteName: "group.com.wepeiyang")!
    
//    static let courseTable = Store<CourseTable>("courseTable")
    static let courseTable = Store<CourseTable>("flutter.courseData")

    static let weather = Store<Weather>("weather")
    
    static func removeAll() {
        UserDefaults.standard.removePersistentDomain(forName: "group.com.wepeiyang")
    }
    
}

protocol Storable {
    init()
}

class Store<T: Codable & Storable>: ObservableObject {
    @Published var object: T
    
    private let key: String
    
    init(_ key: String) {
        self.object = T()
        self.key = key
        
        load()
    }
    
    func load() {

        guard let data = Storage.defaults.data(forKey: key) else {
            return
        }
        
        guard let object = try? JSONDecoder().decode(T.self, from: data) else {
            return
        }
        
        self.object = object
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(object) else {
            return
        }
        
        Storage.defaults.setValue(data, forKey: key)
    }
    
    func remove() {
        Storage.defaults.removeObject(forKey: key)
        self.object = T()
    }
}
