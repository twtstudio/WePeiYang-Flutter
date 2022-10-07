//
//  FlutterWidget.swift
//  FlutterWidget
//
//  Created by Thomas Leiter on 28.10.20.
//

import WidgetKit
import SwiftUI
import Intents


@main
struct PeiYang_LiteBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        WhiteColorWidget()
        BlueColorWidget()
    }
}


struct WhiteColorWidget: Widget {

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "white", provider: CourseTimelineProvider()) { entry in
            CourseTableWidgetEntryView(entry: entry, color: .white)
        }
        .configurationDisplayName("课表信息-白")
        .description("快速查看今明课表信息。")
        .supportedFamilies([.systemSmall])
    }
}

struct BlueColorWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "blue", provider: CourseTimelineProvider()) { entry in
            CourseTableWidgetEntryView(entry: entry, color: .blue)
        }
        .configurationDisplayName("课表信息-蓝")
        .description("快速查看今明课表信息。")
        .supportedFamilies([.systemSmall])
    }
}




struct CourseTableWidgetEntryView: View {
    var entry: CourseTimelineProvider.Entry
    var color: WColorTheme
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
//        case .systemMedium:
//            MediumView(entry: entry)
//        case .systemLarge:
//            LargeView(entry: entry)
//        case .accessoryCircular:
//            LockRingView(entry: entry)
//        case .accessoryInline:
//            LockLineView(entry: entry)
//        case .accessoryRectangular:
//            LockRectView(entry: entry)
        default:
            SmallView(entry: entry, theme: color)
        }
    }
}
