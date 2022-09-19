//
//  LargeView.swift
//  PeiYangLiteWidgetExtension
//
//  Created by 游奕桁 on 2021/1/23.
//

import SwiftUI
import MapKit

struct LargeView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var courseTable: CourseTable = SwiftStorage.courseTable.object
    let entry: DataEntry
    var currentCourseTable: [Course] { entry.courses }
    var weathers = [Weather]()
    var collections: [CollectionClass] { entry.studyRoom }
    var time: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH mm"
        let s = formatter.string(from: Date())
        let t = s.split(separator: " ").map{ Int($0) ?? 0 }
        
        return 60 * t[0] + t[1]
    }
    var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM月dd日"
        let date = dateFormatter.string(from: Date())
        return date
    }
    var weekDay: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let date = dateFormatter.string(from: Date())
        return date
    }
    
    var nowTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date())
    }
    
    // 计算现在的时间处于哪个时间段
    var nowPeriod: Int {
        if nowTime.prefix(2) < "10" && nowTime.prefix(2) >= "00" || (nowTime.prefix(2) == "10" && nowTime.suffix(2) < "05"){
            return 0
        }
        else if nowTime.prefix(2) > "10" && nowTime.prefix(2) < "12" || (nowTime.prefix(2) == "10" && nowTime.suffix(2) >= "05"){
            return 2
        }
        else if nowTime.prefix(2) >= "12" && nowTime.prefix(2) < "15" || (nowTime.prefix(2) == "15" && nowTime.suffix(2) <= "05"){
            return 4
        }
        else if nowTime.prefix(2) > "15" && nowTime.prefix(2) < "17" || (nowTime.prefix(2) == "15" && nowTime.suffix(2) > "05") {
            return 6
        }
        else if nowTime.prefix(2) >= "17" && nowTime.prefix(2) < "20" || (nowTime.prefix(2) == "20" && nowTime.suffix(2) <= "05"){
            return 8
        }
        else {return 10}
    }
    @State var preCourse = WidgetCourse()
    @State var nextCourse = WidgetCourse()
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    Text("天津市")
                        .font(.body)
                        .foregroundColor(colorScheme == .dark ? .white : Color(#colorLiteral(red: 0.1279886365, green: 0.1797681153, blue: 0.2823780477, alpha: 1)))
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                        .foregroundColor(colorScheme == .dark ? .white : Color(#colorLiteral(red: 0.1279886365, green: 0.1797681153, blue: 0.2823780477, alpha: 1)))
                    
                    Spacer()
                    
                    HStack {
                        VStack {
                            Text("\(weathers[0].weatherString)\n\(weathers[0].wStatus)")
                                .font(.footnote)
                        }
                        .foregroundColor(colorScheme == .dark ? .white : Color(#colorLiteral(red: 0.1279886365, green: 0.1797681153, blue: 0.2823780477, alpha: 1)))
                        .multilineTextAlignment(.leading)
                        
                        Image(weathers[0].weatherIconString1)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 35, height: 35)
                    }
                }
                
                Image("line")
                
                HStack {
                    Text(weekDay)
                        .gilroy(style: .body, weight: .bold)
                        .foregroundColor(colorScheme == .dark ? .white : Color(#colorLiteral(red: 0.1279886365, green: 0.1797681153, blue: 0.2823780477, alpha: 1)))
                    
                    Spacer()
                    
                    Text("\(date)  第\(courseTable.currentWeek)周")
                        .font(.footnote)
                        .foregroundColor(colorScheme == .dark ? .white : Color(#colorLiteral(red: 0.1279886365, green: 0.1797681153, blue: 0.2823780477, alpha: 1)))
                }
                
                if currentCourseTable.isEmpty {
                    ZStack {
                        Image("无课背景")
                        
                        Text("今日无课:)做点有意义的事情吧")
                            .font(.body)
                            .foregroundColor(Color(#colorLiteral(red: 0.1279886365, green: 0.1797681153, blue: 0.2823780477, alpha: 1)))
                    }
                } else {
                    
                    HStack {
                        ZStack {
                            Image("NOW")
                                .resizable()
                                .scaledToFit()
                                .frame(width: (geo.size.width-30)/2)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            
                            if !preCourse.isEmpty && !preCourse.isNext {
                                VStack {
                                    Text("\(preCourse.course.name)")
                                        .font(.footnote)
                                        .lineLimit(1)
                                    HStack {
                                        Text("\(preCourse.course.activeArrange(courseTable.currentWeekday).location)")
                                            .font(.system(size: 10))
                                        
                                        Text("\(preCourse.course.activeArrange(courseTable.currentWeekday).startTimeString)-\(preCourse.course.activeArrange(courseTable.currentWeekday).endTimeString)")
                                            .font(.system(size: 10))
                                    }
                                }
                                .padding(.vertical, 4)
                                .padding(.top)
                                .frame(width: (geo.size.width-30)/2)
                                .foregroundColor(.white)
                            } else {
                                Text("当前无课")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        
                        Spacer()
                        
                        ZStack {
                            Image("NEXT")
                                .resizable()
                                .scaledToFit()
                                .frame(width: (geo.size.width-30)/2)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            
                            
                            if !nextCourse.isEmpty {
                                VStack {
                                    Text("\(nextCourse.course.name)")
                                        .font(.footnote)
                                        .lineLimit(1)
                                    HStack {
                                        Text("\(nextCourse.course.activeArrange(courseTable.currentWeekday).location)")
                                            .font(.system(size: 10))
                                        
                                        Text("\(nextCourse.course.activeArrange(courseTable.currentWeekday).startTimeString)-\(nextCourse.course.activeArrange(courseTable.currentWeekday).endTimeString)")
                                            .font(.system(size: 10))
                                    }
                                }
                                .padding(.vertical, 4)
                                .padding(.top)
                                .frame(width: (geo.size.width-30)/2)
                                .foregroundColor(.white)
                            } else {
                                Text("接下来无课")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                            
                            
                        }
                    }
                }
                GeometryReader { g in
                    VStack(alignment: .leading) {
                        Text("自习室")
                            .font(.footnote)
                            .foregroundColor(colorScheme == .dark ? .white : Color(#colorLiteral(red: 0.1279886365, green: 0.1797681153, blue: 0.2823780477, alpha: 1)))
                            .padding(.bottom, 2)
                        
                        HStack(spacing: 10) {
                            if collections.isEmpty {
                                Text("还没有get到你的收藏")
                                    .font(.footnote)
                                    .frame(width: g.size.width, alignment: .center)
                                    .foregroundColor(Color(#colorLiteral(red: 0.4549019608, green: 0.4549019608, blue: 0.537254902, alpha: 1)))
                            } else {
                                ForEach(collections.prefix(4), id:\.id) { collection in
                                    Link(destination: URL(string: "wepeiyang://to/studyroom")!, label: {
                                        RoomCardView(buildingName: collection.buildingName, className: collection.classMessage.classroom, isFree: collection.classMessage.status[nowPeriod] == "0")
                                            .frame(width: (g.size.width - 3 * 10) / 4, height: g.size.height-40)
                                            .background(collection.classMessage.status[nowPeriod] == "0" ? Color(#colorLiteral(red: 0.8519811034, green: 0.8703891039, blue: 0.9223362803, alpha: 1)).cornerRadius(8) : Color(#colorLiteral(red: 0.1279886365, green: 0.1797681153, blue: 0.2823780477, alpha: 1)).cornerRadius(8))
                                    })
                                }
                                if collections.count < 4 {
                                    Spacer()
                                }
                            }
                        }
                        .frame(width: g.size.width)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            (preCourse, nextCourse) = WidgetCourseManager.getPresentAndNextCourse(courseArray: currentCourseTable, weekday: courseTable.currentWeekday, time: time)
            if preCourse.isNext {
                nextCourse = preCourse
                preCourse = WidgetCourse()
            }
        }
    }
}



struct RoomCardView: View {
    var buildingName: String
    var className: String
    var isFree: Bool
    var body: some View {
            VStack {
                Text("\(buildingName)\n\(className)")
                    .font(.system(size: 10))
                    .padding(.bottom, 10)
                
                Text(isFree ? "空闲" : "占用")
                    .font(.footnote)
                    .fontWeight(.bold)
            }
            .foregroundColor(isFree ? Color(#colorLiteral(red: 0.1279886365, green: 0.1797681153, blue: 0.2823780477, alpha: 1)) : Color(#colorLiteral(red: 0.8519811034, green: 0.8703891039, blue: 0.9223362803, alpha: 1)))
    }
}





//struct LargeView_Previews: PreviewProvider {
//    static var previews: some View {
//        LargeView(entry: DataEntry(date: Date(), courses: [Course()], weathers: [Weather()], studyRoom: []))
//    }
//}
