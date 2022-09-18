//
//  CourseTable.swift
//  widgetExtension
//
//  Created by 李佳林 on 2022/9/18.
//

import SwiftUI


struct FlutterData: Decodable, Hashable {
    let text: String
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
    
    // 通过weekday返回课程的活跃安排
    func activeArrange(_ weekday: Int) -> Arrange {
        arrangeArray.first { $0.weekday == weekday } ?? Arrange(teacherArray: [], weekArray: [], weekday: 0, unitArray: [], location: "")
    }
    
    func activeArranges(_ weekday: Int, week: Int? = nil) -> [Arrange] {
        return week != nil ?
        arrangeArray.filter { $0.weekday == weekday }.filter { $0.weekArray.contains(week!) } :
        arrangeArray.filter { $0.weekday == weekday }
    }
    
//    init(fullCourse: [String], arrangePairArray: [(String, Arrange)]) {
//        self.serial = fullCourse[1]
//        self.no = fullCourse[2]
//        self.name = fullCourse[3]
//        self.credit = fullCourse[4]
//        self.teacherArray = fullCourse[5].split(separator: ",").map { String($0).replacingOccurrences(of: "(", with: " (") }
//        self.weeks = fullCourse[6]
//        self.campus = fullCourse[9]
//
//        var arrangeArray = [Arrange]()
//        for (id, arrange) in arrangePairArray {
//            if id == fullCourse[1] {
//                arrangeArray.append(arrange)
//            }
//        }
//        self.arrangeArray = arrangeArray
//    }
    
//    init(dict: [String: String], arrangePairArray: [(String, Arrange)]) {
//        self.serial = dict["serial"] ?? ""
//        self.no = dict["no"] ?? ""
//        self.name = dict["name"] ?? ""
//        self.credit = dict["credit"] ?? ""
//        self.teacherArray = (dict["teacher"] ?? "").split(separator: ",").map { String($0).replacingOccurrences(of: "(", with: " (") }
//        self.weeks = dict["weeks"] ?? ""
//        self.campus = dict["campus"] ?? ""
//
//        var arrangeArray = [Arrange]()
//        for (id, arrange) in arrangePairArray {
//            if id == self.serial {
//                arrangeArray.append(arrange)
//            }
//        }
//
//        self.arrangeArray = arrangeArray
//    }
    
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
    
    var totalWeek: Int {
        courseArray.map { $0.weekRange.max() ?? 1 }.max() ?? 1
    }
    
    var currentCalendar: Calendar {
        var currentCalendar = Calendar.current
        currentCalendar.firstWeekday = 2
        return currentCalendar
    }
    var startDate: Date {
        let dateStr = SharedMessage.semesterStartAt
        let seps = dateStr.components(separatedBy: "-").map { Int($0) ?? 0 }
        guard seps.count == 3 else { return Date() }
        return DateComponents(calendar: currentCalendar, year: seps[0], month: seps[1], day: seps[2]).date ?? Date()
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
        self.customCourseArray = []
    }
    
    init() {
        self.courseArray = []
        self.customCourseArray = []
    }
    
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

