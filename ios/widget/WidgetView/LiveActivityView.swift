//
//  LiveActivityView.swift
//  widgetExtension
//
//  Created by 李佳林 on 2023/8/22.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.1, *)
struct LiveActivityView: View {
    let contentState: LiveActivityAttributes.ContentState
    
    var body: some View {
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
                        Text(message(status: contentState.state))
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(Status.allCases, id: \.self) { type in
                            Image(systemName: type.rawValue)
                                .font(contentState.state == type ? .title2 : .body)
                                .foregroundColor(contentState.state == type ? .blue : .white.opacity(0.7))
                                .frame(width: contentState.state == type ? 45 : 32, height: contentState.state == type ? 45 : 32)
                                .background{
                                    Circle()
                                        .fill(contentState.state == type ? .white : .cyan)
                                }
                                .background(alignment: .bottom, content: {
                                    BottomArrow(status: contentState.state, type: type)
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
