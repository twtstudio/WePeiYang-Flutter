//
//  WidgetCourseManager.swift
//  wbyWidgetsExtension
//
//  Created by 李佳林 on 2022/7/26.
//

import Foundation
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
}
