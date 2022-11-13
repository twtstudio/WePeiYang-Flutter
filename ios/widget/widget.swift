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
        widgets()
    }
    
    private func widgets() -> some Widget {
        if #available(iOS 16.0, *) {
            return WidgetBundleBuilder.buildBlock(
                WhiteColorWidget(),
                BlueColorWidget(),
                LockScreenWidget()
            )
        } else {
            return WidgetBundleBuilder.buildBlock(
                WhiteColorWidget(),
                BlueColorWidget()
            )
        }
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


@available(iOSApplicationExtension 16.0, *)
struct LockScreenWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "lockScreen", provider: CourseTimelineProvider()) { entry in
            LockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("课表信息")
        .description("快速查看今明课表信息。")
        .supportedFamilies([.accessoryRectangular,.accessoryCircular])
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

@available(iOSApplicationExtension 16.0, *)
struct LockScreenWidgetEntryView: View {
    var entry: CourseTimelineProvider.Entry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            LockRingView(entry: entry)
        case .accessoryRectangular:
            LockRectView(entry: entry)
        default:
            LockRingView(entry: entry)
        }
    }
}
