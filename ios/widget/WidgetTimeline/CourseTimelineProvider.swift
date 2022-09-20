//
//  CourseTimelineProvider.swift
//  widgetExtension
//
//  Created by 李佳林 on 2022/9/18.
//

import Foundation
import WidgetKit

struct CourseTimelineProvider: TimelineProvider {
    
    /// 课程表对象
    private let storage = SwiftStorage.courseTable
    private var courseTable: CourseTable {storage.object}
    
    func placeholder(in context: Context) -> DataEntry {
        DataEntry.placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DataEntry) -> Void) {
        completion(DataEntry.placeholder)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<DataEntry>) -> Void) {
        print("xcode: 刷新line")
        
        let currentDate = Date()
        
        let times = Arrange.startTimes + Arrange.endTimes
        var current = Calendar.current.dateComponents(in: TimeZone.current, from: currentDate)
        
        var entries: [DataEntry] = []
        
        var todayValidDates: [Date] = times.map { (h, m) in
            current.hour = h
            current.minute = m
            return Calendar.current.date(from: current)!
        }.filter { d in
            d.compare(currentDate) == .orderedDescending
        }
        
        // 马上来刷新一下
        todayValidDates.insert(Date().addingTimeInterval(3), at: 0)
        // TODO: 删掉无用代码
//        for i in 0..<60 {
//            todayValidDates.insert(Date().addingTimeInterval(TimeInterval(60-i)), at: 0)
//        }
        
        entries += todayValidDates.map { date in
            DataEntry(date: date, courses: getDateCourse(), studyRoom: [])
        }
        
        // 加一天
        current = Calendar.current.dateComponents(in: TimeZone.current, from: currentDate.addingTimeInterval(60 * 60 * 24))
        entries += times.map { (h, m) in
            current.hour = h
            current.minute = m
            return Calendar.current.date(from: current)!
        }.map { date in
            DataEntry(date: date, courses: getDateCourse(tomorrow: true), studyRoom: [])
        }
        print(entries)
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    
    private func getDateCourse(tomorrow: Bool = false) -> [Course] {
        let activeWeek = tomorrow ? courseTable.tomorrowWeek : courseTable.currentWeek
        let activeWeekday = tomorrow ? courseTable.tomorrowDay : courseTable.currentDay
        
        let activeCourseArray: [Course] = courseTable.courseArray.filter {
            $0.weekRange.contains(activeWeek)
        }
        
        let activeCustomCourseArray: [Course] = courseTable.customCourseArray.filter {
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

