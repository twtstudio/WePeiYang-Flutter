//
//  FlutterWidget.swift
//  FlutterWidget
//
//  Created by Thomas Leiter on 28.10.20.
//

import WidgetKit
import SwiftUI
import Intents


struct CourseTableWidgetEntryView: View {
    var entry: CourseTimelineProvider.Entry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
//        case .systemMedium:
//            MediumView(entry: entry)
//        case .systemLarge:
//            LargeView(entry: entry)
        case .accessoryRectangular:
            LockRectView(entry: entry)
        case .accessoryInline:
            LockLineView(entry: entry)
//        case .accessoryCircular:
//            LockRingView(entry: entry)
        default:
            SmallView(entry: entry)
        }
    }
}



@main
struct PeiYang_LiteWidget: Widget {
    let kind: String = "WePeiyangWidget"
    @Environment(\.widgetFamily) var family

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CourseTimelineProvider()) { entry in
            CourseTableWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WePeiyang Widget")
        .description("快速查看当前课表信息。")
        .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryInline])
    }
}
