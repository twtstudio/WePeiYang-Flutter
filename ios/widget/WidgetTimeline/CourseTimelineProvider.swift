//
//  CourseTimelineProvider.swift
//  widgetExtension
//
//  Created by 李佳林 on 2022/9/18.
//

import Foundation
import WidgetKit

struct CourseTimelineProvider: TimelineProvider {
    
    var storage = SwiftStorage.courseTable
    let formatter = DateFormatter()
    var currentCalendar: Calendar {
        var currentCalendar = Calendar.current
        currentCalendar.firstWeekday = 2
        return currentCalendar
    }
    var startDate: Date {
        let dateStr = StorageKey.termStartDate.getGroupData()
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
    
    func getSnapshot(in context: Context, completion: @escaping (DataEntry) -> Void) {
        completion(DataEntry.placeholder)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DataEntry>) -> Void) {
        // 解码flutter传来json
        storage.load()
        let currentDate = Date()
        
        let times = Arrange.startTimes + Arrange.endTimes
        var current = Calendar.current.dateComponents(in: TimeZone.current, from: currentDate)
        var dates = times.map { (h, m) in
            current.hour = h
            current.minute = m
            return Calendar.current.date(from: current)!
        }
        // 加一天
        current = Calendar.current.dateComponents(in: TimeZone.current, from: currentDate.addingTimeInterval(60 * 60 * 24))
        dates += times.map { (h, m) in
            current.hour = h
            current.minute = m
            return Calendar.current.date(from: current)!
        }
        
        // 找到比现在更后的时间
        dates = dates.filter { d in
            d.compare(currentDate) == .orderedDescending
        }
        
        let entries = dates.map { date in
            let entry = DataEntry(date: date, courses: [], studyRoom: [])
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
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
}

extension Date {
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0
    }
}

