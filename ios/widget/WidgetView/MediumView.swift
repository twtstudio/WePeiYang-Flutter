//
//  MidView.swift
//  PeiYangLiteWidgetExtension
//
//  Created by 游奕桁 on 2020/9/17.
//

import SwiftUI
import WidgetKit

struct MediumView: View {
    @Environment(\.colorScheme) private var colorScheme
    var courseTable: CourseTable = SwiftStorage.courseTable.object
    let entry: DataEntry
    var currentCourseTable: [Course] { entry.courses }
    var weathers = [Weather]() 
    var time: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH mm"
        let s = formatter.string(from: Date())
        let t = s.split(separator: " ").map{ Int($0) ?? 0 }
        
        return 60 * t[0] + t[1]
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .center) {
                ZStack {
                    if !currentCourseTable.isEmpty {
                        if let preCourse = WidgetCourseManager.getPresentAndNextCourse(
                            courseArray: currentCourseTable,
                            weekday: courseTable.currentDay,
                            time: time).0 {
                            if preCourse.isNext == false {
                                Image("NOW")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width/2, height: geo.size.height*(5/7))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Image("NEXT")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geo.size.width/2, height: geo.size.height*(5/7))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            if preCourse.isEmpty == false {
                                VStack(spacing: 7) {
                                    Text("\(preCourse.course.name)")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                    
                                    Text("\(preCourse.course.activeArrange(courseTable.currentDay).location)")
                                        .font(.footnote)
                                    
                                    Text("\(preCourse.course.activeArrange(courseTable.currentDay).startTimeString)-\(preCourse.course.activeArrange(courseTable.currentDay).endTimeString)")
                                        .font(.footnote)
                                }
                                .frame(width: geo.size.width*(4/5), height: geo.size.height, alignment: .center)
                                .foregroundColor(.white)
                                .padding(8)
                                .padding(.top, 8)
                            } else {
                                Text("接下来无课")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    else {
                        Image("无课2*4")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width/2, height: geo.size.height*(5/7))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Text("今日无课:)\n做点有意义的事情吧")
                            .font(.footnote)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: geo.size.width*(3/5), height: geo.size.height*(4/5))
                //                .padding(.trailing, 10)
                //                .padding(.leading, geo.size.width/25)
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(weathers[0].weatherIconString1)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading) {
                            Text("今：\(weathers[0].wStatus)")
                                .font(.footnote)
                                .bold()
                            
                            Text("\(weathers[0].weatherString)")
                                .font(.footnote)
                                .bold()
                        }
                        .foregroundColor(colorScheme == .dark ? .white : Color(#colorLiteral(red: 0.1279886365, green: 0.1797681153, blue: 0.2823780477, alpha: 1)))
                    }
                    
                    HStack {
                        Image(weathers[1].weatherIconString1)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading) {
                            Text("明：\(weathers[1].wStatus)")
                                .font(.footnote)
                                .bold()
                            
                            Text("\(weathers[1].weatherString)")
                                .font(.footnote)
                                .bold()
                        }
                        .foregroundColor(colorScheme == .dark ? .white : Color(#colorLiteral(red: 0.1279886365, green: 0.1797681153, blue: 0.2823780477, alpha: 1)))
                    }
                }
            }
            .padding(.top, geo.size.height/9)
            
        }
        
        
    }
}

