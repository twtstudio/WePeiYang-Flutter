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
    var isPlaceHolder = false
}

extension DataEntry {
    static var placeholder: DataEntry {
        DataEntry(date: Date(), isPlaceHolder: true)
    }
}


