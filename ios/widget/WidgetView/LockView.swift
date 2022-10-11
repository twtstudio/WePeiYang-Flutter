//
//  LockView.swift
//  widgetExtension
//
//  Created by 李佳林 on 2022/9/20.
//

import Foundation
import SwiftUI
import WidgetKit

struct LockRectView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var store = SwiftStorage.courseTable
    private var courseTable: CourseTable { store.object }
    let entry: DataEntry
    var currentCourseTable: [Course] { courseTable.courseArray }
    var hour: Int {
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH"
        let hrString = hourFormatter.string(from: Date())
        let hour = Int(hrString) ?? 0
        return hour
    }
    var time: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH mm"
        let s = formatter.string(from: Date())
        let t = s.split(separator: " ").map{ Int($0) ?? 0 }
        
        return 60 * t[0] + t[1]
    }
    
    @State var preCourse = WidgetCourse()
    @State var nextCourse = WidgetCourse()
    
    
    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geo in
                    VStack(alignment: .leading) {
                        if !currentCourseTable.isEmpty {
                            HStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(colorScheme == .dark ? Color(#colorLiteral(red: 0.2358871102, green: 0.5033512712, blue: 0.9931854606, alpha: 1)) : Color(#colorLiteral(red: 0.3056178987, green: 0.3728546202, blue: 0.4670386314, alpha: 1)))
                                    .frame(width: 3, height: 33)
                                    .padding(.leading, 6)
                                    if !nextCourse.isEmpty {
                                        VStack(alignment: .leading) {
                                            Text("\(nextCourse.course.name)")
                                                .font(.system(size: 16))
                                                .fontWeight(.bold)
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                                .lineLimit(1)
                                            HStack {
                                                Text("\(nextCourse.course.activeArrange(courseTable.currentDay).location)")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(colorScheme == .dark ? .white : .gray)
                                                
                                                Text("\(nextCourse.course.activeArrange(courseTable.currentDay).startTimeString)-\(nextCourse.course.activeArrange(courseTable.currentDay).endTimeString)")
                                                    .font(.system(size: 11))
                                                    .foregroundColor(colorScheme == .dark ? .white : .gray)
                                            }
                                        }
                                    } else {
                                        Text("接下来没有课:)")
                                            .font(.footnote)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                    }
                            }
                            
                        } else {
                            Text((hour>21 || hour<4) ? "夜深了\n做个早睡的人吧" : "今日无课:)\n做点有意义的事情吧")
                                .font(.footnote)
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .padding([.leading, .top])
                        }
                        
                    }
                }
            }
            .padding(.top, 15)
        }
        .onAppear {
            (preCourse, nextCourse) = WidgetCourseManager.getPresentAndNextCourse(courseArray: currentCourseTable, weekday: courseTable.currentDay, time: time)
            if preCourse.isNext {
                nextCourse = preCourse
                preCourse = WidgetCourse()
            }
        }
    }
}







struct LockLineView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var store = SwiftStorage.courseTable
    private var courseTable: CourseTable { store.object }
    let entry: DataEntry
    var currentCourseTable: [Course] { courseTable.courseArray }
    var hour: Int {
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH"
        let hrString = hourFormatter.string(from: Date())
        let hour = Int(hrString) ?? 0
        return hour
    }
    var time: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH mm"
        let s = formatter.string(from: Date())
        let t = s.split(separator: " ").map{ Int($0) ?? 0 }
        
        return 60 * t[0] + t[1]
    }
    
    @State var preCourse = WidgetCourse()
    @State var nextCourse = WidgetCourse()
    
    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geo in
                    VStack(alignment: .leading) {
                        if !currentCourseTable.isEmpty {
                            HStack {
                                if !preCourse.isEmpty {
                                        Text("\(preCourse.course.name)")
                                        .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                            .lineLimit(1)
                                    VStack(alignment: .leading){
                                        Text("\(preCourse.course.activeArrange(courseTable.currentDay).location)")
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                        
                                        Text("\(preCourse.course.activeArrange(courseTable.currentDay).startTimeString)-\(preCourse.course.activeArrange(courseTable.currentDay).endTimeString)")
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                    }
                                }
                                else {
                                    Text("当前没有课:)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        } else {
                            Text((hour>21 || hour<4) ? "夜深了早睡吧:)" : "今日无课:)")
                                .font(.footnote)
                                .bold()
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .padding([.leading, .top])
                        }
                        
                    }
                }
            }
            .padding(.top, 15)
        }
        .onAppear {
            (preCourse, nextCourse) = WidgetCourseManager.getPresentAndNextCourse(courseArray: currentCourseTable, weekday: courseTable.currentDay, time: time)
            if preCourse.isNext {
                nextCourse = preCourse
                preCourse = WidgetCourse()
            }
        }
    }
    
}


@available(iOSApplicationExtension 16.0, *)
struct LockRingView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var store = SwiftStorage.courseTable
    private var courseTable: CourseTable { store.object }
    let entry: DataEntry
    var currentCourseTable: [Course] { courseTable.courseArray }
    var hour: Int {
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH"
        let hrString = hourFormatter.string(from: Date())
        let hour = Int(hrString) ?? 0
        return hour
    }
    var time: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH mm"
        let s = formatter.string(from: Date())
        let t = s.split(separator: " ").map{ Int($0) ?? 0 }

        return 60 * t[0] + t[1]
    }

    @State var preCourse = WidgetCourse()
    @State var nextCourse = WidgetCourse()


    var body: some View {
        ZStack {
            VStack {
                GeometryReader { geo in
                    if !nextCourse.isEmpty {
                        ZStack{
                            Text("\(nextCourse.course.name)")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .lineLimit(2)
                                .frame(width: 45)
//                            RingView
                        }
                    } else {
                        ZStack{
                            AccessoryWidgetBackground()
                            Text("没有课:)")
                                .font(.footnote)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                }
            }
            .padding(.top, 15)
        }
        .onAppear {
            (preCourse, nextCourse) = WidgetCourseManager.getPresentAndNextCourse(courseArray: currentCourseTable, weekday: courseTable.currentDay, time: time)
            if preCourse.isNext {
                nextCourse = preCourse
                preCourse = WidgetCourse()
            }
        }
    }
}
//

