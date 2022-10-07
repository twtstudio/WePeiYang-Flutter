//
//  FontTool.swift
//
//  Created by 游奕桁 on 2021/1/27.
//

import SwiftUI

enum WFont {
    case pingfang, sfpro, product
    
    func fontName() -> String {
        switch self {
        case .pingfang:
            return "PingFangSC-Medium"
        case .sfpro:
            return "sf-pro-text-regular"
        case .product:
            return "Product Sans Bold"
        }
    }
}

extension View {
    func wfont(_ type: WFont, size: CGFloat) -> some View {
        self.font(.custom(type.fontName(), size: size))
    }
}
