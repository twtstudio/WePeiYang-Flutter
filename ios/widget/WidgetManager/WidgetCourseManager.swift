//
//  WidgetCourseManager.swift
//
//  Created by Zr埋 on 2021/9/14.
//

import SwiftUI

struct WidgetCourse {
    var isNext: Bool
    var course: Course
    var isEmpty: Bool
    
    init() {
        isNext = false
        course = Course()
        isEmpty = true
    }
}

struct WCourse {
    /// 是否为当前课程
    var isCurrent: Bool = false
    /// 是否为今天课程
    var isToday: Bool = false
    /// 是否有重复课程
    var isDup: Bool = false
    /// 课程
    var course: Course = Course()
    /// 安排
    var arrange: Arrange = Arrange()
}

struct WidgetCourseManager {
    static func getPresentAndNextCourse(courseArray: [Course], weekday: Int, time: Int) -> (WidgetCourse, WidgetCourse) {
        var presentCourse = WidgetCourse()
        var nextCourse = WidgetCourse()
        
        var isNext = false
        
        // 判断是否为下一节课
        var i = 0
        while i < courseArray.count {
            let arrange = courseArray[i].activeArrange(weekday)
            if (arrange.startTime.0 * 60 + arrange.startTime.1) > time {
                isNext = true
                break
            }
            if (arrange.startTime.0 * 60 + arrange.startTime.1) <= time && (arrange.endTime.0 * 60 + arrange.endTime.1) > time {
                break
            }
            i += 1
        }
        
        if i < courseArray.count {
            // 找到present课
            presentCourse.isEmpty = false
            presentCourse.isNext = isNext
            presentCourse.course = courseArray[i]
            
            // 如果有下一节课
            if i < courseArray.count - 1 {
                nextCourse.course = courseArray[i + 1]
                nextCourse.isNext = true
                nextCourse.isEmpty = false
            }
        }
        
        return (presentCourse, nextCourse)
    }
    
    static func getCourses(courseTable: CourseTable) -> [WCourse] {
        let current = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
        // 现在的分钟总数
        let curMin = current.hour! * 60 + current.minute!
        
        // `flat`实现了将[[E]]中的[E]拼接到一起的作用，最后类型为[(Arrange), Course]
        let array = courseTable.courseArray.flatMap { course in
            (course.activeArranges(courseTable.currentDay, week: courseTable.currentWeek) +
             course.activeArranges(courseTable.tomorrowDay, week: courseTable.tomorrowWeek))
            // 夹带course一起返回
            .map { ($0, course) }
        }.filter { tup in
            let arrange = tup.0
            // 如果已经结束了就不要了
            if arrange.weekday == courseTable.currentDay && arrange.endTime.0 * 60 + arrange.endTime.1 < curMin {
                return false
            }
            return true
        }
        // 排序，按照arrange大小排序
            .sorted { $0.0 < $1.0 }
        
        
        // 需要计算是否重复，所以重新查看下
        var result: [WCourse] = []
        // 用于比较
        var tmpTup = (0, 0)
        var tmpDay = courseTable.currentDay
        var i = 0
        while i < array.count {
            let tup = array[i]
            // 不是同一天或者不是同个时间
            if tup.0.startTime != tmpTup || tup.0.weekday != tmpDay {
                let st = tup.0.startTime.0 * 60 + tup.0.startTime.1
                result.append(WCourse(
                    isCurrent: st > curMin,
                    isToday: tup.0.weekday == courseTable.currentDay,
                    isDup: false,
                    course: tup.1,
                    arrange: tup.0
                ))
                
                tmpTup = tup.0.startTime
                tmpDay = tup.0.weekday
            } else {
                // 一定有冲突
                result[result.count-1].isDup = true
            }
            i += 1
        }
        return result
    }
}






