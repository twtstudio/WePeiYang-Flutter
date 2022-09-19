//
//  CourseEntry.swift
//  PeiYangLiteWidgetExtension
//
//  Created by 游奕桁 on 2020/9/17.
//

import Foundation
import WidgetKit

struct DataEntry: TimelineEntry {
    let date: Date
    let courses: [Course]
    let studyRoom: [CollectionClass]
    var isPlaceHolder = false
}

extension DataEntry {
    static var placeholder: DataEntry {
        DataEntry(date: Date(), courses: [], studyRoom: [], isPlaceHolder: true)
    }
}


