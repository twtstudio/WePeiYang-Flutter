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
    var currentCourseTable: [Course] { entry.courses }
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
    var weekday: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        //        let avaliable = Locale.availableIdentifiers
        //        print(avaliable)
        dateFormatter.locale = Locale(identifier: "en_CH")
        dateFormatter.dateFormat = "EEEE"
        let dayInWeek = dateFormatter.string(from: date)
        return dayInWeek
    }
    
    @State var preCourse = WidgetCourse()
    @State var nextCourse = WidgetCourse()
    
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(weekday)
                        .morningStar(style: .largeTitle, weight: .bold)
                        .foregroundColor(colorScheme == .dark ? Color(#colorLiteral(red: 0.2358871102, green: 0.5033512712, blue: 0.9931854606, alpha: 1)) : Color(#colorLiteral(red: 0.6872389913, green: 0.7085373998, blue: 0.8254910111, alpha: 1)))
                        .padding(.leading, -3)
                    
                    Spacer()
                    
                }
                GeometryReader { geo in
                    VStack(alignment: .leading) {
                        if !currentCourseTable.isEmpty {
                            HStack {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(colorScheme == .dark ? Color(#colorLiteral(red: 0.2358871102, green: 0.5033512712, blue: 0.9931854606, alpha: 1)) : Color(#colorLiteral(red: 0.3056178987, green: 0.3728546202, blue: 0.4670386314, alpha: 1)))
                                        .frame(width: 3, height: 28)
                                        .padding(.leading, 6)
                                    
                                    if !preCourse.isEmpty {
                                        VStack(alignment: .leading) {
                                            Text("\(preCourse.course.name)")
                                                .font(.footnote)
                                                .fontWeight(.bold)
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                                .lineLimit(1)
                                            HStack {
                                                Text("\(preCourse.course.activeArrange(courseTable.currentWeekday).location)")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray)
                                                
                                                Text("\(preCourse.course.activeArrange(courseTable.currentWeekday).startTimeString)-\(preCourse.course.activeArrange(courseTable.currentWeekday).endTimeString)")
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
                                    .fill(colorScheme == .dark ? Color(#colorLiteral(red: 0.2358871102, green: 0.5033512712, blue: 0.9931854606, alpha: 1)) : Color(#colorLiteral(red: 0.3056178987, green: 0.3728546202, blue: 0.4670386314, alpha: 1)))
                                    .frame(width: 3, height: 28)
                                    .padding(.leading, 6)
                                    if !nextCourse.isEmpty {
                                        VStack(alignment: .leading) {
                                            Text("\(nextCourse.course.name)")
                                                .font(.footnote)
                                                .fontWeight(.bold)
                                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                                .lineLimit(1)
                                            HStack {
                                                Text("\(nextCourse.course.activeArrange(courseTable.currentWeekday).location)")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(colorScheme == .dark ? .white : .gray)
                                                
                                                Text("\(nextCourse.course.activeArrange(courseTable.currentWeekday).startTimeString)-\(nextCourse.course.activeArrange(courseTable.currentWeekday).endTimeString)")
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
                            Text(hour>21 ? "夜深了\n做个早睡的人吧" : "今日无课:)\n做点有意义的事情吧")
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
            (preCourse, nextCourse) = WidgetCourseManager.getPresentAndNextCourse(courseArray: currentCourseTable, weekday: courseTable.currentWeekday, time: time)
            print(preCourse, nextCourse)
        }
    }
    
}
