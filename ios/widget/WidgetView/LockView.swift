//
//  LockView.swift
//  widgetExtension
//
//  Created by 李佳林 on 2022/9/20.
//

import Foundation
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct LockRectView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var store = SwiftStorage.courseTable
    private var courseTable: CourseTable { store.object }
    @State var courses : [WCourse] = []
    @State var time = String()
    let entry: DataEntry
    var body: some View {
        ZStack(alignment: .leading) {
            if((courses.count) != 0){
                VStack(alignment: .leading){
                    HStack{
                        Image(systemName: "clock")
                            .resizable()
                            .frame(width: 14, height: 14)
                            .padding(.trailing, -4)
                        Text("\(courses[0].arrange.unitTimeString)")
                            .lineLimit(1)
                            .font(.system(size: 15,weight: .semibold))
                            

                    }
                    .padding(.bottom, -6)
                    
                    Text(courses[0].course.name)
                        .lineLimit(1)
                        .font(.system(size: 15, weight: .medium))
                    Text("\(courses[0].arrange.location)")
                        .lineLimit(1)
                        .font(.system(size: 15, weight: .medium))
                        .opacity(0.76)
                }
            } else {
                Text("接下来没有课呢！")
                    .font(.system(size: 15))
            }
        }
        .padding(.leading, -12)
        .onAppear {
            store.reloadData()
            courses = WidgetCourseManager.getCourses(courseTable: courseTable)
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
    @State var courses : [WCourse] = []

    let entry: DataEntry
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            if(courses.count != 0) {
                VStack(spacing: -1){
                    Text(courses[0].arrange.startTimeString)
                        .font(.system(size: 12, weight: .regular))
                    Text((courses[0].arrange.location.components(separatedBy: "楼").count >= 2) ? courses[0].arrange.location.components(separatedBy: "楼")[0] : " ")
                        .font(.system(size: 15,weight: .bold))
                    Text((courses[0].arrange.location.components(separatedBy: "楼").count >= 2) ? courses[0].arrange.location.components(separatedBy: "楼")[1] : " ")
                        .font(.system(size: 12, weight: .regular))
                        .opacity(0.98)
                }
            } else {
                Text("暂时没课")
            }
        }
        .onAppear {
            store.reloadData()
            courses = WidgetCourseManager.getCourses(courseTable: courseTable)
        }
    }
}


