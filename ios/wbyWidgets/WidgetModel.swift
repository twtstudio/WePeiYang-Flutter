//
//  WidgetModel.swift
//  wbyWidgetsExtension
//
//  Created by 李佳林 on 2022/7/26.
//

import Foundation
import SwiftUI
import WidgetKit

struct Arrange: Codable, Storable, Comparable, Hashable {
    var teacherArray: [String]
    let weekArray: [Int] // 1...
    let weekday: Int // 0...
    let unitArray: [Int] // 0...
    let location: String
    
    // Teacher
    var teachers: String { teacherArray.joined(separator: ", ") }
    
    // Week
    var firstWeek: Int { weekArray.first ?? 1 }
    var lastWeek: Int { weekArray.last ?? 1 }
    var weekString: String { "\(firstWeek)-\(lastWeek)" }
    
    // Unit
    var length: Int { unitArray.count }
    var startUnit: Int { unitArray.first ?? 0 }
    var endUnit: Int { startUnit + length }
    var startTime: (Int, Int) {
        guard startUnit >= 0 && startUnit < 12 else {
            return (8, 30)
        }
        return [
            (8, 30), (9, 20), (10, 25), (11, 15),
            (13, 30), (14, 20), (15, 25), (16, 15),
            (18, 30), (19, 20), (20, 10), (21, 0)
        ][startUnit]
    }
    var startTimeString: String { String(format: "%02d:%02d", startTime.0, startTime.1) }
    var endTime: (Int, Int) {
        guard endUnit - 1 >= 0 && endUnit - 1 < 12 else {
            return (9, 15)
        }
        return [
            (9, 15), (10, 5), (11, 10), (12, 0),
            (14, 15), (15, 5), (16, 10), (17, 0),
            (19, 15), (20, 5), (20, 55), (21, 45)
        ][endUnit - 1]
    }
    var endTimeString: String { String(format: "%02d:%02d", endTime.0, endTime.1) }
    var unitString: String { "\(startUnit + 1)-\(startUnit + length)" }
    var unitTimeString: String { "\(startTimeString)-\(endTimeString)" }
    
    var uuid: String { teachers + weekString + weekday.description + unitString + location }
    
    init(teacherArray: [String], weekArray: [Int], weekday: Int, unitArray: [Int], location: String) {
        self.teacherArray = teacherArray
        self.weekArray = weekArray
        self.weekday = weekday
        self.unitArray = unitArray
        self.location = location
    }
    
    init() {
        self.teacherArray = []
        self.weekArray = []
        self.weekday = 0
        self.unitArray = []
        self.location = ""
    }
    
    static func < (lhs: Arrange, rhs: Arrange) -> Bool {
        if lhs.firstWeek != rhs.firstWeek {
            return lhs.firstWeek < rhs.firstWeek
        } else if lhs.weekday != rhs.weekday {
            return lhs.weekday < rhs.weekday
        } else if lhs.startUnit != rhs.startUnit {
            return lhs.startUnit < rhs.startUnit
        } else {
            return lhs.teachers < rhs.teachers
        }
    }
}


struct Course: Codable, Storable, Equatable, Hashable {
    
    let serial: String
    let no: String
    let name: String
    let credit: String
    let teacherArray: [String]
    let weeks: String
    let campus: String
    let arrangeArray: [Arrange]
    
    var teachers: String { teacherArray.joined(separator: ", ") }
    
    var weekRange: ClosedRange<Int> {
        let weekArray = weeks.split(separator: "-").map { Int($0) ?? 0 }
        return weekArray.count == 2 ? weekArray[0]...weekArray[1] : 1...1
    }
    
    // 通过weekday返回课程的活跃安排
    func activeArrange(_ weekday: Int) -> Arrange {
        arrangeArray.first { $0.weekday == weekday } ?? Arrange(teacherArray: [], weekArray: [], weekday: 0, unitArray: [], location: "")
    }
    
    func activeArranges(_ weekday: Int, week: Int? = nil) -> [Arrange] {
        return week != nil ?
        arrangeArray.filter { $0.weekday == weekday }.filter { $0.weekArray.contains(week!) } :
        arrangeArray.filter { $0.weekday == weekday }
    }
    
    init(fullCourse: [String], arrangePairArray: [(String, Arrange)]) {
        self.serial = fullCourse[1]
        self.no = fullCourse[2]
        self.name = fullCourse[3]
        self.credit = fullCourse[4]
        self.teacherArray = fullCourse[5].split(separator: ",").map { String($0).replacingOccurrences(of: "(", with: " (") }
        self.weeks = fullCourse[6]
        self.campus = fullCourse[9]

        var arrangeArray = [Arrange]()
        for (id, arrange) in arrangePairArray {
            if id == fullCourse[1] {
                arrangeArray.append(arrange)
            }
        }
        self.arrangeArray = arrangeArray
    }
    
    init(dict: [String: String], arrangePairArray: [(String, Arrange)]) {
        self.serial = dict["serial"] ?? ""
        self.no = dict["no"] ?? ""
        self.name = dict["name"] ?? ""
        self.credit = dict["credit"] ?? ""
        self.teacherArray = (dict["teacher"] ?? "").split(separator: ",").map { String($0).replacingOccurrences(of: "(", with: " (") }
        self.weeks = dict["weeks"] ?? ""
        self.campus = dict["campus"] ?? ""

        var arrangeArray = [Arrange]()
        for (id, arrange) in arrangePairArray {
            if id == self.serial {
                arrangeArray.append(arrange)
            }
        }
//        print(arrangeArray)
//        var arrangeSet = [Arrange]()
//        for arrange in arrangeArray {
//            let ar = arrangeSet.firstIndex(where: { $0.weekday == arrange.weekday &&
//                $0.unitArray == arrange.unitArray &&
//                $0.weekArray == arrange.weekArray })
//            if ar != nil {
//                arrangeSet[ar!].teacherArray.append(contentsOf: arrange.teacherArray)
//            } else {
//                arrangeSet.append(arrange)
//            }
//        }
        
        self.arrangeArray = arrangeArray
    }
    
    init() {
        self.serial = ""
        self.no = ""
        self.name = ""
        self.credit = ""
        self.teacherArray = [""]
        self.weeks = ""
        self.campus = ""
        self.arrangeArray = []
    }
}

struct CourseTable: Codable, Storable {
    var courseArray: [Course]
    
    var totalWeek: Int {
        courseArray.map { $0.weekRange.max() ?? 1 }.max() ?? 1
    }
    
    var currentCalendar: Calendar {
        var currentCalendar = Calendar.current
        currentCalendar.firstWeekday = 2
        return currentCalendar
    }
    var startDate: Date {
        //ToDo: 用flutter数据
//        if let dateStr = ClassesManager.classTerm?.semesterStartAt {
//            let seps = dateStr.components(separatedBy: "-").map { Int($0) ?? 0 }
//            guard seps.count == 3 else { return Date() }
//            return DateComponents(calendar: currentCalendar, year: seps[0], month: seps[1], day: seps[2]).date ?? Date()
//        }
        
        return Date()
    }
    private var endDate: Date { Date(timeInterval: TimeInterval(totalWeek * 7 * 24 * 60 * 60), since: startDate) }
    var currentDate: Date {
        // TODO: Dynamic calculated
        let currentDate = Date()
        if currentDate < startDate {
            return startDate
        } else if currentDate > endDate {
            return endDate
        } else {
            return currentDate
        }
        // test date
//        DateComponents(calendar: currentCalendar, year: 2021, month: 9, day: 29, hour: 6, minute: 10).date ?? Date()
    }
    
    var currentMonth: String { currentDate.format(with: "LLL") }
    
    var currentDay: Int { currentCalendar.component(.day, from: currentDate) }
    
    private var weekDistance: Double { startDate.distance(to: currentDate) / (7 * 24 * 60 * 60) }
    private var passedWeek: Double { floor(weekDistance) }
    var currentWeek: Int { weekDistance == 0 ? 1 : Int(ceil(weekDistance)) }
    
    var currentWeekStartDay: Int {
        let currentWeekStartDate = startDate.addingTimeInterval(passedWeek * 7 * 24 * 60 * 60)
        return currentCalendar.component(.day, from: currentWeekStartDate)
    }
    
    var currentWeekday: Int {
        let weekdayDistance = weekDistance - passedWeek
        return Int(floor(weekdayDistance * 7))
    }
    
    init(courseArray: [Course]) {
        self.courseArray = courseArray
    }
    
    init() {
        self.courseArray = []
    }
}

struct Storage {
    static let defaults = UserDefaults(suiteName: "group.com.wepeiyang")!
    
    static let courseTable = Store<CourseTable>("courseTable")
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


struct Weather: Codable, Storable {
    var wStatus: String = ""
    var wTempH: String = ""
    var wTempL: String = ""
    var weatherString: String = ""
    var weatherIconString1: String = ""
    var weatherIconString2: String = ""
    
    init() {
    }
    
}


struct DataEntry: TimelineEntry {
    let date: Date
    let courses: [Course]
    let weathers: [Weather]
    let studyRoom: [CollectionClass]
    var isPlaceHolder = false
}
extension DataEntry {
    static var placeholder: DataEntry {
        DataEntry(date: Date(), courses: [], weathers: [Weather(), Weather()], studyRoom: [], isPlaceHolder: true)
    }
}


// MARK: - Classroom
struct Classroom: Codable, Identifiable, Hashable {
    var id = UUID()
    let classroomID, classroom, status: String
   

    enum CodingKeys: String, CodingKey {
        case classroomID = "classroom_id"
        case classroom, status
    }
}

// MARK: - 收藏储存结构体
struct CollectionClass: Hashable, Encodable, Identifiable {
    var id = UUID()
    var sectionName: String
    var classMessage: Classroom
    var buildingName: String
}


// MARK: - ColorHelper
struct ColorHelper {
    let color: [String: Color]
    
    static var shared = ColorHelper(Storage.courseTable.object.courseArray)
    
    init(_ courseArray: [Course]) {
        var colorArray = [
            #colorLiteral(red: 0.5590268373, green: 0.5717645288, blue: 0.645496428, alpha: 1), #colorLiteral(red: 0.4453202486, green: 0.4580122828, blue: 0.5316858888, alpha: 1), #colorLiteral(red: 0.5585952401, green: 0.4775523543, blue: 0.5879413486, alpha: 1), #colorLiteral(red: 0.512439549, green: 0.524015069, blue: 0.6323540807, alpha: 1), #colorLiteral(red: 0.3847824335, green: 0.396281302, blue: 0.4800215364, alpha: 1), #colorLiteral(red: 0.6332313418, green: 0.6521518826, blue: 0.7899104953, alpha: 1), #colorLiteral(red: 0.6195089221, green: 0.5867381692, blue: 0.7159363031, alpha: 1), #colorLiteral(red: 0.6934235692, green: 0.6567432284, blue: 0.8013477921, alpha: 1),
            #colorLiteral(red: 0.4496340156, green: 0.3764404655, blue: 0.4869975448, alpha: 1), #colorLiteral(red: 0.6253550649, green: 0.5235865116, blue: 0.6773356795, alpha: 1), #colorLiteral(red: 0.7457726598, green: 0.6244233251, blue: 0.8077706695, alpha: 1), #colorLiteral(red: 0.4722867608, green: 0.5927650928, blue: 0.6177451015, alpha: 1), #colorLiteral(red: 0.4739673138, green: 0.6488676667, blue: 0.6929715872, alpha: 1), #colorLiteral(red: 0.2412205935, green: 0.3298183084, blue: 0.3522273302, alpha: 1), #colorLiteral(red: 0.218701601, green: 0.3526560962, blue: 0.2918043733, alpha: 1), #colorLiteral(red: 0.04705882353, green: 0.2784313725, blue: 0.4039215686, alpha: 1)
        ].map { Color($0) }
        
        var color = [String: Color]()
        
        for course in courseArray {
            colorArray.shuffle()
            color[course.no] = colorArray.popLast() ?? .orange
        }
        
        self.color = color
    }
    
    init(colorArray: [Color]) {
        var colorArray = colorArray
        let courseArray = Storage.courseTable.object.courseArray
        var color = [String: Color]()

        for course in courseArray {
            colorArray.shuffle()
            color[course.no] = colorArray.popLast() ?? Color(hex: 0xefd9e5)
        }

        self.color = color
    }
}


// MARK: - extension Date
extension Date {
    func format(with format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

// MARK: - extension Color
extension Color {
    init(hex: Int, alpha: Double = 1) {
        let components = (
            R: Double((hex >> 16) & 0xff) / 255,
            G: Double((hex >> 08) & 0xff) / 255,
            B: Double((hex >> 00) & 0xff) / 255
        )
        self.init(
            .sRGB,
            red: components.R,
            green: components.G,
            blue: components.B,
            opacity: alpha
        )
    }
}
