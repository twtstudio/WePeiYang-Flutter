//
//  CourseTable.swift
//  widgetExtension
//
//  Created by 李佳林 on 2022/9/18.
//

import SwiftUI
import ActivityKit


struct FlutterData: Decodable, Hashable {
    let text: String
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
// 收藏储存结构体
struct CollectionClass: Hashable, Encodable, Identifiable {
    var id = UUID()
    var sectionName: String
    var classMessage: Classroom
    var buildingName: String
}

struct Arrange: Codable, Storable, Comparable, Hashable {
    var teacherArray: [String]
    let weekArray: [Int] // 1...
    let weekday: Int // 0...
    let unitArray: [Int] // 0...
    let location: String
    
    enum CodingKeys: String, CodingKey {
        case location = "location"
        case weekday = "weekday"
        case weekArray = "weekList"
        case unitArray = "unitList"
        case teacherArray = "teacherList"
    }
    
    // Teacher
    var teachers: String { teacherArray.joined(separator: ", ") }
    
    // Week
    var firstWeek: Int { weekArray.first ?? 1 }
    var lastWeek: Int { weekArray.last ?? 1 }
    var weekString: String { "\(firstWeek)-\(lastWeek)" }
    
    // Unit
    var length: Int { unitArray.count }
    var startUnit: Int { unitArray[0] }
    var endUnit: Int { unitArray[1] }
    
    /// 所有课程开始时间
    static let startTimes = [
        (8, 30), (9, 20), (10, 25), (11, 15),
        (13, 30), (14, 20), (15, 25), (16, 15),
        (18, 30), (19, 20), (20, 10), (21, 0),
    ]
    /// 所有课程结束时间
    static let endTimes = [
        (9, 15), (10, 5), (11, 10), (12, 0),
        (14, 15), (15, 5), (16, 10), (17, 0),
        (19, 15), (20, 5), (20, 55), (21, 45),
    ]
    
    var startTime: (Int, Int) {
        guard startUnit > 0 && startUnit < 12 else {
            return Arrange.startTimes[0]
        }
        return Arrange.startTimes[startUnit - 1]
    }
    var startTimeString: String { String(format: "%02d:%02d", startTime.0, startTime.1) }
    var endTime: (Int, Int) {
        guard endUnit > 0 && endUnit <= 12 else {
            return Arrange.endTimes[0]
        }
        return Arrange.endTimes[endUnit - 1]
    }
    var endTimeString: String { String(format: "%02d:%02d", endTime.0, endTime.1) }
    var unitString: String { "\(startUnit)-\(startUnit + length - 1)" }
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
        if lhs.weekday != rhs.weekday {
            return lhs.weekday < rhs.weekday
        } else if lhs.startUnit != rhs.startUnit {
            return lhs.startUnit < rhs.startUnit
        } else {
            return lhs.teachers < rhs.teachers
        }
    }
}

struct Course: Codable, Storable, Equatable, Hashable {
    
    let name: String
    let serial: String  //serial,逻辑班号
    let no: String   //课程代码
    let type: Int
    let credit: String
    let teacherArray: [String]
    let weeks: String
    let campus: String
    let arrangeArray: [Arrange]
    
    
    
    enum CodingKeys: String, CodingKey {
        case name
        
        case serial = "classId"
        case no = "courseId"
        case credit, campus ,weeks
        case teacherArray = "teacherList"
        case arrangeArray = "arrangeList"
        case type
        
    }
    
    var teachers: String { teacherArray.joined(separator: ", ") }
    
    var weekRange: ClosedRange<Int> {
        let weekArray = weeks.split(separator: "-").map { Int($0) ?? 0 }
        return weekArray.count == 2 ? weekArray[0]...weekArray[1] : 1...1
    }
    
    /// 通过weekday返回课程的活跃安排
    func activeArrange(_ weekday: Int) -> Arrange {
        arrangeArray.first { $0.weekday == weekday } ?? Arrange(teacherArray: [], weekArray: [], weekday: 0, unitArray: [], location: "")
    }
    
    /// 返回这周
    func activeArranges(_ weekday: Int, week: Int) -> [Arrange] {
        arrangeArray.filter { $0.weekday == weekday }.filter { $0.weekArray.contains(week) }
    }
    
    init() {
        self.serial = ""
        self.no = ""
        self.type = 0
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
    var customCourseArray: [Course]
    
    enum CodingKeys: String, CodingKey {
        case courseArray = "schoolCourses"
        case customCourseArray = "customCourses"
    }
    
    /// 一周的秒数
    private let WEEK_SECONDS: Int = 7 * 24 * 60 * 60
    
    var totalWeek: Int {
        // TODO: 先写死吧
        30
    }
    
    var currentCalendar: Calendar {
        Calendar.current
    }
    var startDate: Date {
        let dateStr = StorageKey.termStartDate.getGroupData()
        let seps = dateStr.components(separatedBy: "-").map { Int($0) ?? 0 }
        guard seps.count == 3 else { return Date() }
        return DateComponents(calendar: currentCalendar, timeZone: TimeZone.current, year: seps[0], month: seps[1], day: seps[2]).date ?? Date()
    }
    
    var endDate: Date { Date(timeInterval: TimeInterval(totalWeek * WEEK_SECONDS), since: startDate) }
    
    /// 返回有效的时间，仅可能在学期的开始和结束期间
    var currentDate: Date {
        let currentDate = Date()
        if currentDate < startDate {
            return startDate
        } else if currentDate > endDate {
            return endDate
        } else {
            return currentDate
        }
    }
    
    /// 当前周数
    var currentWeek: Int {
        let d = currentCalendar.dateComponents([.second], from: startDate, to: currentDate).second ?? 0
        return Int(ceil(Double(d) / Double(60 * 60 * 24 * 7))) 
    }
    
    /// 今天星期几
    var currentDay: Int {
        // 默认是从周日开始
        let day = currentCalendar.dateComponents(in: TimeZone.current, from: currentDate).weekday! - 1
        return day == 0 ? 7 : day
    }
    
    /// 明天周数
    var tomorrowWeek: Int {
        // 如果是周日(1)就是week+1
        currentDay == 1 ? currentWeek + 1 : currentWeek
    }
    
    /// 明天星期几
    var tomorrowDay: Int {
        let day = currentDay + 1
        return day == 8 ? 1 : day
    }
    
    init(courseArray: [Course]) {
        self.courseArray = courseArray
        self.customCourseArray = []
    }
    
    init() {
        self.courseArray = []
        self.customCourseArray = []
    }
    
}

// MARK: - LiveActivity
struct LiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var status: Status = .perpare
    }
    
    var courseName: String
}

enum Status: String, CaseIterable, Codable, Equatable {
    case perpare = "figure.walk.motion"
    case ongoing = "rectangle.inset.filled.and.person.filled"
    case over = "checkmark.seal"
}

extension Date {
    func format(with format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension String {
    subscript (i: Int) -> Character? {
        guard i < self.count else {
            return nil
        }
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (r: Range<Int>) -> String? {
        guard (r.lowerBound >= 0 && r.upperBound <= self.count) else { return nil }
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start..<end])
    }
    
    subscript (r: ClosedRange<Int>) -> String? {
        guard (r.lowerBound >= 0 && r.upperBound < self.count) else { return nil }
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start...end])
    }
    func firstIndex(of element: Character) -> Int {
        return self.distance(from: self.startIndex, to: self.firstIndex(of: element) ?? self.startIndex) - 1
    }
    func lastIndex(of element: Character) -> Int {
        return self.distance(from: self.startIndex, to: self.lastIndex(of: element) ?? self.endIndex) - 1
    }
    func findFirst(_ sub:String)->Int {
        var pos = -1
        if let range = range(of:sub, options: .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    func find(_ pattern: String, at group: Int = 1) -> String {
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        } catch {
            return ""
        }
        
        guard let match = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else {
            return ""
        }
        
        guard let range = Range(match.range(at: group), in: self) else {
            return ""
        }
        
        return String(self[range])
    }
    
    func findArray(_ pattern: String, at group: Int = 1) -> [String] {
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        } catch {
            return []
        }
        
        let matches = regex.matches(in: self, options: .withoutAnchoringBounds, range: NSRange(location: 0, length: self.count))
        
        var array = [String]()
        for match in matches {
            guard let range = Range(match.range(at: group), in: self) else {
                return []
            }
            array.append(String(self[range]))
        }
        
        return array
    }
    
    // Good Alternative!
    func findArrays(_ pattern: String) -> [[String]] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
            let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.count))
            
            return matches.map { match in
                return (0..<match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: self) else {
                        return ""
                    }
                    return String(self[range])
                }
            }
        } catch {
            return []
        }
    }
}

// to pass Detail
class CourseConfig: ObservableObject {
    @Published var showDetail: Bool = false
    @Published var currentCourses: [(Course, Arrange)] = []
    @Published var isConflict: Bool = false
    @Published var currentWeekday = 0
}

