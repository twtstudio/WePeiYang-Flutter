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
        if #available(iOS 16.1, *) {
            return WidgetBundleBuilder.buildBlock(
                WhiteColorWidget(),
                BlueColorWidget(),
                LockScreenWidget(),
                LiveActivityWidget()
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

@available(iOSApplicationExtension 16.1, *)
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

@available(iOSApplicationExtension 16.1, *)
struct LiveActivityWidget: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self){ context in
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.blue.gradient)
                
                VStack {
                    HStack(spacing: 20) {
                        Image("peiyanglogo-blue")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                        
                        Text("26教 A207")
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "figure.walk.motion")
                            .foregroundColor(.white)
                            .background{
                                Circle()
                                    .fill(.blue)
                                    .padding(-2)
                            }
                            .background{
                                Circle()
                                    .stroke(.white, lineWidth:1.5)
                                    .padding(-2)
                            }
                    }
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("测试课程-实时活动")
                                .font(.body)
                                .foregroundColor(.white)
                            Text(message(status: context.state.status))
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(alignment: .bottom, spacing: 0) {
                            ForEach(Status.allCases, id: \.self) { type in
                                Image(systemName: type.rawValue)
                                    .font(context.state.status == type ? .title2 : .body)
                                    .foregroundColor(context.state.status == type ? .blue : .white.opacity(0.7))
                                    .frame(width: context.state.status == type ? 45 : 32, height: context.state.status == type ? 45 : 32)
                                    .background{
                                        Circle()
                                            .fill(context.state.status == type ? .white : .cyan)
                                    }
                                    .background(alignment: .bottom, content: {
                                        BottomArrow(status: context.state.status, type: type)
                                    })
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .overlay(alignment: .bottom, content: {
                            Rectangle()
                                .fill(.white.opacity(0.6))
                                .frame(height: 2)
                                .offset(y: 12)
                                .padding(.horizontal, 27.5)
                        })
                        .padding(.leading, 15)
                        .padding(.trailing, -10)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 10)
                }
                .padding(15)
            }
                .activityBackgroundTint(Color.blue)
        } dynamicIsland: { context in
            DynamicIsland{
                // Expend when long pressed
                DynamicIslandExpandedRegion(.leading){
                    HStack {
                        Spacer()
                        Image("peiyanglogo-white")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                        
                        Text("26教 A207")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                DynamicIslandExpandedRegion(.trailing){
                    HStack {
//                        Image(systemName: "figure.walk.motion")
//                            .foregroundColor(.white)
//                            .background{
//                                Circle()
//                                    .fill(.blue)
//                                    .padding(-2)
//                            }
//                            .background{
//                                Circle()
//                                    .stroke(.white, lineWidth:1.5)
//                                    .padding(-2)
//                            }
//                            .padding(.trailing, 5)
                        
                        DynamicIslandProgressView(process: 0.3)
                        
                        Text("30min")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                DynamicIslandExpandedRegion(.center){
//                    Text("Hello")
                }
                DynamicIslandExpandedRegion(.bottom){
                    DynamicIslandStatusView(context: context)
                        .padding(.bottom, 10)
                }
            } compactLeading: {
                Image(systemName: context.state.status.rawValue)
                    .font(.title3)
                    .foregroundColor(.white)
            } compactTrailing: {
                DynamicIslandProgressView(process: 0.3)
            } minimal: {
                Image(systemName: context.state.status.rawValue)
                    .font(.title3)
                    .foregroundColor(.white)
            }
        }
    }
    
    @ViewBuilder
    func DynamicIslandProgressView(process: Double) -> some View {
//        let rotation = process > 1 ? 1 : (process < 0 ? 0 : process)
        ZStack {
            Image(systemName: "arrow.up")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .fontWeight(.semibold)
                .frame(width: 12, height: 12)
                .foregroundColor(.blue)
                .rotationEffect(.init(degrees: Double(process * 360)))
            //MARK: Progress Ring
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.25), lineWidth: 4)
                
                Circle()
                    .trim(from: 0, to: process)
                    .stroke(.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.init(degrees: -90))
            }
            .frame(width: 23, height: 23)
        }
    }
    
    @ViewBuilder
    func DynamicIslandStatusView(context: ActivityViewContext<LiveActivityAttributes>) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("测试课程-实时活动")
                    .font(.callout)
                    .foregroundColor(.white)
                Text(message(status: context.state.status))
                    .font(.caption2)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: 5, y: 5)
            
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(Status.allCases, id: \.self) { type in
                    Image(systemName: type.rawValue)
                        .font(context.state.status == type ? .title2 : .body)
                        .foregroundColor(context.state.status == type ? .blue : .white.opacity(0.7))
                        .frame(width: context.state.status == type ? 35 : 26, height: context.state.status == type ? 35 : 26)
                        .background{
                            Circle()
                                .fill(context.state.status == type ? .white : .cyan)
                        }
                        .background(alignment: .bottom, content: {
                            BottomArrow(status: context.state.status, type: type)
                        })
                        .frame(maxWidth: .infinity)
                }
            }
            .overlay(alignment: .bottom, content: {
                Rectangle()
                    .fill(.white.opacity(0.6))
                    .frame(height: 2)
                    .offset(y: 12)
                    .padding(.horizontal, 27.5)
            })
            .offset(y: -5)
        }
    }
    
    @ViewBuilder
    func BottomArrow(status: Status, type: Status) -> some View {
        Image(systemName: "arrowtriangle.down.fill")
            .font(.system(size: 15))
            .scaleEffect(1.3)
            .offset(y: 6)
            .opacity(status == type ? 1 : 0)
            .foregroundColor(.white)
            .overlay(alignment: .bottom) {
                Circle()
                    .fill(.white)
                    .frame(width: 5, height: 5)
                    .offset(y: 13)
            }
    }
    
    func message(status: Status) -> String {
        switch status {
        case .perpare:
            return "准备上课"
        case .ongoing:
            return "上课中"
        case .over:
            return "已完成"
        }
    }
}

@available(iOSApplicationExtension 16.2, *)
struct LiveActivityView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            LiveActivityAttributes(courseName: "测试课程-实时活动")
                .previewContext(
                    LiveActivityAttributes.ContentState(),
                    viewKind: .content
                )
            
            LiveActivityAttributes(courseName: "测试课程-实时活动")
                .previewContext(
                    LiveActivityAttributes.ContentState(),
                    viewKind: .dynamicIsland(.expanded)
                )
        }
    }
}


struct CourseTableWidgetEntryView: View {
    var entry: CourseTimelineProvider.Entry
    var color: WColorTheme
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if #available(iOSApplicationExtension 16.1, *) {
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

@available(iOSApplicationExtension 16.1, *)
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
