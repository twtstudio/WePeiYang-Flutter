//
//  widgetHandler.swift
//  Runner
//
//  Created by TwT on 2022/9/19.
//

import WidgetKit
import Flutter

extension Channel {
    private func reloadWidgetData() {
        Channel.reloadWidgetData()
    }
    
    static func reloadWidgetData() {
        // 将User Defaults中的数据存到文件里
        StorageKey.saveToGroupStorage()
        // 刷新小组件timeline
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func getDateCourse(courseTable: CourseTable, tomorrow: Bool = false) -> [Course] {
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
    
    func widgetHandler() -> FlutterMethodCallHandler {
        return { call, result in
//            var dict: [String: Any] = [:]
//            if let callDict = call.arguments {
//                dict = callDict as? [String: Any] ?? [:]
//            }
            switch call.method {
            case "refreshScheduleWidget":
                reloadWidgetData()
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
