//
//  CourseTimelineProvider.swift
//  Runner
//
//  Created by 李佳林 on 2022/7/26.
//

import Foundation
import WidgetKit

struct CourseTimelineProvider: TimelineProvider {
    var storage = Storage.courseTable
    var courseTable: CourseTable { storage.object }
    let formatter = DateFormatter()
//    var endDate: Date{
//        formatter.dateFormat = "YYYYMMdd"
//        return formatter.date(from: "20210816")!
//    }
    var currentCalendar: Calendar {
        var currentCalendar = Calendar.current
        currentCalendar.firstWeekday = 2
        return currentCalendar
    }
    var startDate: Date {
//        if let dateStr = ClassesManager.classTerm?.semesterStartAt {
//            let seps = dateStr.components(separatedBy: "-").map { Int($0) ?? 0 }
//            guard seps.count == 3 else { return Date() }
//            return DateComponents(calendar: currentCalendar, year: seps[0], month: seps[1], day: seps[2]).date ?? Date()
//        }
        
        return Date()
    }
    private var endDate: Date { Date(timeInterval: TimeInterval(courseTable.totalWeek * 7 * 24 * 60 * 60), since: startDate) }
    var totalDays: Int {
        endDate.daysBetweenDate(toDate: Date())
    }
    var todayWeek: Int {
        totalDays / 7 + 1
    }
    var todayDay: Int {
        totalDays % 7 + 1
    }
    var nowTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date())
    }
    
    func placeholder(in context: Context) -> DataEntry {
        DataEntry.placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DataEntry) -> Void) {
        completion(DataEntry.placeholder)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DataEntry>) -> Void) {
        let currentDate = Date()
        var entries: [DataEntry] = []
        let firstDate = getFirstEntryDate()
        let firstMin = getFirstMinuteEntryDate()
//        for offset in 0..<60 {
//            let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
            let courses = getTodayCourse()
        
//            WeatherService().weatherGet { result in
//                var weathers: [Weather]
//                switch result {
//                case .success(let weather):
//                    weathers = weather
//
//                case .failure(let error):
//                    weathers = [Weather(), Weather()]
//                    log.error("获取天气错误", context: error)
//                }
//                getCollection { (res) in
//                    var classCollections: [CollectionClass] = []
//                    switch res {
//                    case .success(let collections):
//                        classCollections = collections
//                    case .failure(let err):
//                        log.error("获取天气错误", context: err)
//                    }
//                    entries.append(DataEntry(date: firstDate, courses: courses, weathers: weathers, studyRoom: classCollections))
//                    entries.append(DataEntry(date: firstMin, courses: courses, weathers: weathers, studyRoom: classCollections))
//                    for offset in 0..<60 {
//                        let refreshDate = Calendar.current.date(byAdding: .minute, value: offset, to: currentDate)!
//                        let entry = DataEntry(date: refreshDate, courses: courses, weathers: weathers, studyRoom: classCollections)
//                        entries.append(entry)
//                    }
//                    let timeline = Timeline(entries: entries, policy: .atEnd)
//                    completion(timeline)
//                }
////        }
//        }
//        }
    }
    
    private func getFirstEntryDate() -> Date {
        let offsetSecond: TimeInterval = TimeInterval(2)
        var currentDate = Date()
        currentDate += offsetSecond
        return currentDate
    }
    
    private func getFirstMinuteEntryDate() -> Date {
        var currentDate = Date()
        let passSecond = Calendar.current.component(.second, from: currentDate)
        let offsetSecond: TimeInterval = TimeInterval(60 - passSecond)
        currentDate += offsetSecond
        return currentDate
    }
    
    private func getTodayCourse() -> [Course] {
        let activeWeek = courseTable.currentWeek
        let activeWeekday = courseTable.currentWeekday
        
        let activeCourseArray: [Course] = courseTable.courseArray.filter {
            $0.weekRange.contains(activeWeek)
        }
        
        var currentCourseArray: [Course] = activeCourseArray.filter { course in
            return course.arrangeArray
                .filter { $0.weekArray.contains(activeWeek) }
                .map(\.weekday)
                .contains(activeWeekday)
        }
        // 进行排序
        currentCourseArray.sort { (c1, c2) -> Bool in
            let a1 = c1.activeArrange(activeWeekday)
            let a2 = c2.activeArrange(activeWeekday)
            return a1.startUnit < a2.startUnit
        }
        
        return currentCourseArray
        
    }
    
//    private func getCollection(completion: @escaping (Result<[CollectionClass], Network.Failure>) -> Void) {
//        guard let termName = ClassesManager.classTerm?.semesterName else { return }
//        StudyRoomManager.allBuidlingGet(term: termName, week: String(todayWeek), day: String(todayDay)) { result in
//            switch result {
//            case .success(let data):
//                if(data.errorCode == 0) {
//                    StyCollectionManager.getCollections(buildings: data.data) {result in
//                        switch result {
//                        case .success(let data):
//                            completion(.success(data))
//                        case .failure(let error):
//                            completion(.failure(error))
//                        }
//                    }
//                }
//            case .failure(let error):
//                log.error("加载失败", context: error)
//                completion(.failure(error))
//            }
//        }
//    }
    
//    private func requestDataToUseData(buildings: [StudyBuilding], completion: @escaping (Result<[CollectionClass], Network.Failure>) -> Void) {
//        
//    }
    
}

extension Date {
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0
    }
}

    

