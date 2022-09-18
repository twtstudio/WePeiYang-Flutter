//
//  CourseTimelineProvider.swift
//  widgetExtension
//
//  Created by 李佳林 on 2022/9/18.
//

import Foundation
import WidgetKit

struct CourseTimelineProvider: IntentTimelineProvider {
    
    var storage = Storage.courseTable
//    var courseTable: CourseTable { storage.object }
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
        let dateStr = SharedMessage.semesterStartAt
        let seps = dateStr.components(separatedBy: "-").map { Int($0) ?? 0 }
        guard seps.count == 3 else { return Date() }
        return DateComponents(calendar: currentCalendar, year: seps[0], month: seps[1], day: seps[2]).date ?? Date()
    }
    private var endDate: Date { Date(timeInterval: TimeInterval(storage.object.totalWeek * 7 * 24 * 60 * 60), since: startDate) }
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
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (DataEntry) -> Void) {
        completion(DataEntry.placeholder)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<DataEntry>) -> Void) {
        storage.load()  //解码flutter传来json
        let currentDate = Date()
        var entries: [DataEntry] = []
        let firstDate = getFirstEntryDate()
        let firstMin = getFirstMinuteEntryDate()
//        for offset in 0..<60 {
//            let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let courses = getTodayCourse()
        
            WeatherService().weatherGet { result in
                var weathers: [Weather]
                switch result {
                case .success(let weather):
                    weathers = weather
                case .failure(_):
                    weathers = [Weather(), Weather()]
                    print("获取天气错误")
                }
//                getCollection { (res) in
//                    var classCollections: [CollectionClass] = []
//                    switch res {
//                    case .success(let collections):
//                        classCollections = collections
//                    case .failure(_):
//                        print("获取天气错误")
//                    }
                entries.append(DataEntry(date: firstDate, courses: courses, weathers: weathers, studyRoom: []))
                    entries.append(DataEntry(date: firstMin, courses: courses, weathers: weathers, studyRoom: []))
                    for offset in 0..<60 {
                        let refreshDate = Calendar.current.date(byAdding: .minute, value: offset, to: currentDate)!
                        let entry = DataEntry(date: refreshDate, courses: courses, weathers: weathers, studyRoom: [])
                        entries.append(entry)
                    }
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
//                }
//        }
        }
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
        let activeWeek = storage.object.currentWeek
        let activeWeekday = storage.object.currentWeekday
        
        let activeCourseArray: [Course] = storage.object.courseArray.filter {
            $0.weekRange.contains(activeWeek)
        }
        
        let activeCustomCourseArray: [Course] = storage.object.customCourseArray.filter {
            $0.weekRange.contains(activeWeek)
        }
        
        let totalActiveCourseArray: [Course] = activeCourseArray + activeCustomCourseArray
        
        var currentCourseArray: [Course] = totalActiveCourseArray.filter { course in
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
//        let termName = SharedMessage.semesterName
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
//                print("加载失败")
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

