//
//  FlutterWidget.swift
//  FlutterWidget
//
//  Created by Thomas Leiter on 28.10.20.
//

import WidgetKit
import SwiftUI
import Intents



//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let flutterData: FlutterData?
//}
//
//struct Provider: IntentTimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), flutterData: FlutterData(text: "Hello from Flutter"))
//    }
//
//    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), flutterData: FlutterData(text: "Hello from Flutter"))
//        completion(entry)
//    }
//
//    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        let sharedDefaults = UserDefaults.init(suiteName: "group.com.wepeiyang")
//        var flutterData: FlutterData? = nil
//
//        if(sharedDefaults != nil) {
//            do {
//              let shared = sharedDefaults?.string(forKey: "widgetData")
//              if(shared != nil){
//                let decoder = JSONDecoder()
//                flutterData = try decoder.decode(FlutterData.self, from: shared!.data(using: .utf8)!)
//              }
//            } catch {
//              print(error)
//            }
//        }
//
//        let currentDate = Date()
//        let entryDate = Calendar.current.date(byAdding: .hour, value: 24, to: currentDate)!
//        let entry = SimpleEntry(date: entryDate, flutterData: flutterData)
//        entries.append(entry)
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//}
//
//struct FlutterWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    private var FlutterDataView: some View {
//        Text(SharedMessage.username)
//    }
//
//    private var NoDataView: some View {
//      Text("No Data found! Go to the Flutter App")
//    }
//
//    var body: some View {
//      if(entry.flutterData == nil) {
//        NoDataView
//      } else {
//        FlutterDataView
//      }
//    }
//}

struct CourseTableWidgetEntryView: View {
    var entry: CourseTimelineProvider.Entry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemMedium:
            MediumView(entry: entry)
        case .systemLarge:
            LargeView(entry: entry)
        default:
            SmallView(entry: entry)
        }
    }
}



@main
struct WePeiyang_Widget: Widget {
    let kind: String = "WePeiyangWidget"
    @Environment(\.widgetFamily) var family

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: CourseTimelineProvider()) { entry in
            CourseTableWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WePeiyang Widget")
        .description("快速查看当前课表信息。")
        .supportedFamilies([.systemMedium, .systemSmall, .systemLarge])
    }
}

//struct PeiYangLiteWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        MediumView(currentCourseTable: [Course()], weathers: [Weather()])
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//    }
//}
