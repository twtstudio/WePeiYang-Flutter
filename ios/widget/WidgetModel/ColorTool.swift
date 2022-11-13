//
//  ColorTool.swift
//  widgetExtension
//
//  Created by Zr埋 on 2022/10/6.
//
import SwiftUI
import UIKit

enum WColorTheme: CaseIterable {
    case white, blue
}

enum WColor: CaseIterable {
    case main,
         title,
         body
    
    private func sumColor(_ c1: Color, _ c2: Color, _ darkColor: Color, _ theme: WColorTheme, _ colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            return darkColor
        }
        switch theme {
        case .white:
            return c1
        case .blue:
            return c2
        }   
    }
    
    func color(theme: WColorTheme, colorScheme: ColorScheme) -> Color {
        switch self {
        case .main:
            return sumColor(.hex("#376EE8"), .hex("#FFFFFF"), .hex("#4976DA"), theme, colorScheme)
        case .title:
            return sumColor(.hex("#2A2A2A"), .hex("#FFFFFF"), .hex("#FFFFFF").opacity(0.8), theme, colorScheme)
        case .body:
            return sumColor(.hex("#7D7B7E"), .hex("#FFFFFF"), .hex("#C2C2C2"), theme, colorScheme)
        }
    }
}

extension Color {
    static func hex(_ h:String) -> Color {
        var cString:String = h.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            if #available(iOSApplicationExtension 15.0, *) {
                return Color(uiColor: UIColor.gray)
            } else {
                return Color(UIColor.gray)
            }
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        let uiColor = UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
        
        if #available(iOSApplicationExtension 15.0, *) {
            return Color(uiColor: uiColor)
        } else {
            return Color(uiColor)
        }
        
    }
    
    static func wColor(_ type: WColor, _ property: ColorProperty) -> Color {
        type.color(theme: property.wTheme, colorScheme: property.colorTheme)
    }
}

struct ColorProperty {
    var wTheme: WColorTheme
    var colorTheme: ColorScheme
}
