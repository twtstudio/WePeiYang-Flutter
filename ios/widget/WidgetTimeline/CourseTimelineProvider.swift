//
//  CourseTimelineProvider.swift
//  widgetExtension
//
//  Created by 李佳林 on 2022/9/18.
//

import Foundation
import WidgetKit
import UIKit

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
        // TODO: 完善timeline刷新
        let currentDate = Date()
        
        var times = Arrange.startTimes + Arrange.endTimes
        // 夜猫子模式，和新的一天
        times += [
            (22, 0), (24, 0)
        ]
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
        
        entries += todayValidDates.map { date in
            DataEntry(date: date)
        }
        
        // 加一天
        current = Calendar.current.dateComponents(in: TimeZone.current, from: currentDate.addingTimeInterval(60 * 60 * 24))
        entries += times.map { (h, m) in
            current.hour = h
            current.minute = m
            return Calendar.current.date(from: current)!
        }.map { date in
            DataEntry(date: date)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

extension Date {
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0
    }
}

