//
//  FontTool.swift
//
//  Created by 游奕桁 on 2021/1/27.
//

import SwiftUI

struct MorningStarModifier: ViewModifier {
    var style: UIFont.TextStyle = .body
    var weight: Font.Weight = .regular

    func body(content: Content) -> some View {
        content
            .font(Font.custom("MorningStar", size: UIFont.preferredFont(forTextStyle: style).pointSize)
            .weight(weight))
    }
    
}

struct GilroyModifier: ViewModifier {
    var style: UIFont.TextStyle = .body
    var weight: Font.Weight = .regular

    func body(content: Content) -> some View {
        content
            .font(Font.custom("Gilroy-Bold", size: UIFont.preferredFont(forTextStyle: style).pointSize)
            .weight(weight))
    }
    
}

extension View {
    func morningStar(style: UIFont.TextStyle, weight: Font.Weight) -> some View {
        self.modifier(MorningStarModifier(style: style, weight: weight))
    }
    
    func gilroy(style: UIFont.TextStyle, weight: Font.Weight) -> some View {
        self.modifier(GilroyModifier(style: style, weight: weight))
    }
}
