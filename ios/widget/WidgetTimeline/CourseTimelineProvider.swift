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
        let currentDate = Date()
        
        var times = Arrange.startTimes + Arrange.endTimes
        // 夜猫子模式，和新的一天
        times += [
            (22, 0), (24 + 0, 0), (24 + 6, 0)
        ]
        times = times.sorted { t1, t2 in
            t1.0*60+t1.1 < t2.0*60+t2.1
        }

        let zeroDate = Date.zero()
        
        var todayValidDates: [Date] = times.map { (h, m) in
            zeroDate.addingTimeInterval(TimeInterval((60 * h + m) * 60))
        }.filter { $0 >= currentDate }
        // 马上来刷新一下
        todayValidDates.insert(currentDate.addingTimeInterval(3), at: 0)
        
        let entries  = todayValidDates.map { date in
            DataEntry(date: date)
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

extension Date {
    /// 今天的0点0分0秒
    static func zero() -> Date {
        var zero = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        zero.hour = 0
        zero.minute = 0
        zero.second = 0
        return Calendar.current.date(from: zero) ?? Date()
    }
    
    func daysBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: toDate)
        return components.day ?? 0
    }
}

