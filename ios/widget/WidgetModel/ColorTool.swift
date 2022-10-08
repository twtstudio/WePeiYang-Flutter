//
//  ColorTool.swift
//  widgetExtension
//
//  Created by Zr埋 on 2022/10/6.
//
import SwiftUI

enum WColorTheme: CaseIterable {
    case white, blue
}

enum WColor: CaseIterable {
    case main,
         title,
         body
    
    private func sumColor(_ c1: Color, _ c2: Color, _ darkColor: Color, _ theme: WColorTheme) -> Color {
        @Environment(\.colorScheme) var colorScheme
        if colorScheme == .dark {
            return darkColor
        }
        if theme == .white {
            return c1
        } else {
            return c2
        }
    }
    
    func color(theme: WColorTheme) -> Color {
        switch self {
        case .main:
            return sumColor(.hex("#376EE8"), .hex("#FFFFFF"), .hex("#FFFFFF"), theme)
        case .title:
            return sumColor(.hex("#2A2A2A"), .hex("#FFFFFF"), .hex("#FFFFFF"), theme)
        case .body:
            return sumColor(.hex("#7D7B7E"), .hex("#FFFFFF"), .hex("#FFFFFF"), theme)
        }
    }
}


extension Color {
    static func hex(_ h:String) -> Color {
        var cString:String = h.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return Color(uiColor: UIColor.gray)
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return Color(uiColor: UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        ))
    }
    
    static func wColor(_ type: WColor, _ theme: WColorTheme) -> Color {
        return type.color(theme: theme)
    }
}
