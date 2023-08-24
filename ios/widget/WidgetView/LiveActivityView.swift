//
//  LiveActivityView.swift
//  widgetExtension
//
//  Created by 李佳林 on 2023/8/22.
//

import SwiftUI

struct LiveActivityView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.green)
        }
    }
}

#Preview {
    LiveActivityView()
}
