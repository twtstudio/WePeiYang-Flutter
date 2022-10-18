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
        LockScreenWidget()
    }
}


struct WhiteColorWidget: Widget {

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "white", provider: CourseTimelineProvider()) { entry in
            CourseTableWidgetEntryView(entry: entry, color: .white)
        }
        .configurationDisplayName("课表信息-白")
        .description("快速查看今明课表信息。")
        .supportedFamilies([.systemSmall,.systemMedium])
    }
}

struct BlueColorWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "blue", provider: CourseTimelineProvider()) { entry in
            CourseTableWidgetEntryView(entry: entry, color: .blue)
        }
        .configurationDisplayName("课表信息-蓝")
        .description("快速查看今明课表信息。")
        .supportedFamilies([.systemSmall,.systemMedium])
    }
}

struct LockScreenWidget: Widget {
    var body: some WidgetConfiguration {
        if #available(iOSApplicationExtension 16.0, *) {
            return StaticConfiguration(kind: "lockScreen", provider: CourseTimelineProvider()) { entry in
                CourseTableWidgetEntryView(entry: entry, color: .blue)
            }
            .configurationDisplayName("课表信息")
            .description("快速查看今明课表信息。")
            .supportedFamilies([.accessoryRectangular,.accessoryCircular])
        } else {
            return StaticConfiguration(kind: "lockScreen", provider: CourseTimelineProvider()) { entry in
                CourseTableWidgetEntryView(entry: entry, color: .blue)
            }
            .configurationDisplayName("课表信息")
            .description("快速查看今明课表信息。")
            .supportedFamilies([])
        }
    }
}



struct CourseTableWidgetEntryView: View {
    var entry: CourseTimelineProvider.Entry
    var color: WColorTheme
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if #available(iOSApplicationExtension 16.0, *) {
            switch family {
            case .systemMedium:
                MediumView(entry: entry, theme: color)
            case .accessoryCircular:
                LockRingView(entry: entry)
            case .accessoryRectangular:
                LockRectView(entry: entry)
            default:
                SmallView(entry: entry, theme: color)
            }
        } else {
            switch family {
            case .systemMedium:
                MediumView(entry: entry, theme: color)
            default:
                SmallView(entry: entry, theme: color)
            }
        }
    }
}
