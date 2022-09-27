//
//  smallView.swift
//  Runner
//
//  Created by 李佳林 on 2022/9/18.
//

import SwiftUI
import WidgetKit


struct SmallView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var store = SwiftStorage.courseTable
    private var courseTable: CourseTable { store.object }
    let entry: DataEntry
    var currentCourses: [Course] {entry.courses}
    var hour: Int {
        Calendar.current.dateComponents(in: TimeZone.current, from: Date()).hour ?? 0
    }
    var time: Int {
        let t = Calendar.current.dateComponents(in: TimeZone.current, from: Date().addingTimeInterval(-7 * 60 * 60))
        return t.hour! * 60 + t.minute!
    }
    var weekday: String {
        Date().format(with: "EEEE")
    }
    
    @State var preCourse = WidgetCourse()
    @State var nextCourse = WidgetCourse()
    
    var body: some View {
        VStack {
            HStack {
                Image({ () -> String in
                    switch weekday{
                    case "Monday": return "Mon.b"
                    case "Tuesday": return "Tue.b"
                    case "Wednesday": return "Wed.b"
                    case "Thursday": return "Thu.b"
                    case "Friday": return "Fri.b"
                    case "Saturday": return "Sat.b"
                    default: return "Sun.b"
                    }
                }())
                .padding(.leading)
                .padding(.top, 10)

                Spacer()
                Image("beiyangb")
                    .padding(.top, -10)
                    .padding(.trailing)
            }
            
            
            GeometryReader { geo in
                VStack(alignment: .leading) {
                    if !currentCourses.isEmpty {
                        HStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(colorScheme == .dark ? Color(#colorLiteral(red: 0.2358871102, green: 0.5033512712, blue: 0.9931854606, alpha: 1)) : Color(#colorLiteral(red: 0.22, green: 0.43, blue: 0.91, alpha: 1)))
                                    .frame(width: 4, height: 28)
                                    .padding(.leading, 16)
                                    .padding(.trailing, -4)
                                if !preCourse.isEmpty {
                                    VStack(alignment: .leading) {
                                        Text("\(preCourse.course.name)")
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                            .lineLimit(1)
                                        HStack {
                                            Text("\(preCourse.course.activeArrange(courseTable.currentDay).location)")
                                                .font(.system(size: 10))
                                                .foregroundColor(.gray)
                                            
                                            Text("\(preCourse.course.activeArrange(courseTable.currentDay).startTimeString)-\(preCourse.course.activeArrange(courseTable.currentDay).endTimeString)")
                                                .font(.system(size: 10))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                else {
                                    Text("当前没有课:)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                        }
                        
                        
                        HStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(colorScheme == .dark ? Color(#colorLiteral(red: 0.2358871102, green: 0.5033512712, blue: 0.9931854606, alpha: 1)) : Color(#colorLiteral(red: 0.22, green: 0.43, blue: 0.91, alpha: 1)))
                                .frame(width: 4, height: 28)
                                .padding(.leading, 16)
                                .padding(.trailing, -4)

                                if !nextCourse.isEmpty {
                                    VStack(alignment: .leading) {
                                        Text("\(nextCourse.course.name)")
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                            .lineLimit(1)
                                        HStack {
                                            Text("\(nextCourse.course.activeArrange(courseTable.currentDay).location)")
                                                .font(.system(size: 10))
                                                .foregroundColor(colorScheme == .dark ? .white : .gray)
                                            
                                            Text("\(nextCourse.course.activeArrange(courseTable.currentDay).startTimeString)-\(nextCourse.course.activeArrange(courseTable.currentDay).endTimeString)")
                                                .font(.system(size: 10))
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
                        Text("这两天都没有课程啦，\n假期愉快！")
                            .font(.system(size: 10))
                            .fontWeight(.regular)
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(.leading)
                            .padding(.top, 25)
                    }
                    
                }
            }
        }
        .padding(.top, 15)
        .onAppear {
            (preCourse, nextCourse) = WidgetCourseManager.getPresentAndNextCourse(courseArray: currentCourses, weekday: courseTable.currentDay, time: time)
        }
    }
}
