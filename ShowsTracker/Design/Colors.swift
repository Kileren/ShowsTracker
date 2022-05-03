//
//  Colors.swift
//  ShowsTracker
//
//  Created by s.bogachev on 31.01.2021.
//

import SwiftUI

extension Color {
    static let backgroundLight = Color(#colorLiteral(red: 0.9882352941, green: 0.9843137255, blue: 0.9921568627, alpha: 1))
    static let backgroundDark = Color(#colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1))
    static let backgroundDarkEl1 = Color(#colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1))
    static let backgroundDarkEl2 = Color(#colorLiteral(red: 0.2196078431, green: 0.2196078431, blue: 0.2196078431, alpha: 1))
    
    static let text100 = Color(#colorLiteral(red: 0.2745098039, green: 0.2784313725, blue: 0.3411764706, alpha: 1))
    static let text60 = Color(#colorLiteral(red: 0.2745098039, green: 0.2784313725, blue: 0.3411764706, alpha: 0.6))
    static let text40 = Color(#colorLiteral(red: 0.2745098039, green: 0.2784313725, blue: 0.3411764706, alpha: 0.4))
    static let text20 = Color(#colorLiteral(red: 0.2745098039, green: 0.2784313725, blue: 0.3411764706, alpha: 0.2))
    static let text10 = Color(#colorLiteral(red: 0.2745098039, green: 0.2784313725, blue: 0.3411764706, alpha: 0.1))
    
    static let bay = Color(#colorLiteral(red: 0.2117647059, green: 0.2666666667, blue: 0.7803921569, alpha: 1))
    static let bayDark = Color(#colorLiteral(red: 0.337254902, green: 0.3882352941, blue: 0.8196078431, alpha: 1))
    static let graySimple = Color(#colorLiteral(red: 0.8941176471, green: 0.8941176471, blue: 0.8941176471, alpha: 1))
    static let separators = Color(#colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1))
    
    static let redLight = Color(#colorLiteral(red: 0.9960784314, green: 0.2862745098, blue: 0.2862745098, alpha: 1))
    static let redSoft = Color(#colorLiteral(red: 0.9921568627, green: 0.431372549, blue: 0.4352941176, alpha: 1))
    static let redBackground = Color(#colorLiteral(red: 1, green: 0.7607843137, blue: 0.7647058824, alpha: 1))
    static let orangeSoft = Color(#colorLiteral(red: 0.9921568627, green: 0.6274509804, blue: 0.2823529412, alpha: 1))
    static let yellowSoft = Color(#colorLiteral(red: 1, green: 0.7568627451, blue: 0.02745098039, alpha: 1))
    static let greenHard = Color(#colorLiteral(red: 0, green: 0.7607843137, blue: 0.3843137255, alpha: 1))
    static let greenLight = Color(#colorLiteral(red: 0, green: 0.8980392157, blue: 0.4549019608, alpha: 1))
    static let greenSoft = Color(#colorLiteral(red: 0.2549019608, green: 0.8862745098, blue: 0.5764705882, alpha: 1))
    static let greenBackground = Color(#colorLiteral(red: 0.7098039216, green: 1, blue: 0.8470588235, alpha: 1))
    
    static let white100 = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    static let white60 = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6))
    static let white40 = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4))
}

extension Gradient {
    static let skeletonBackground = Gradient(colors: [Color(red: 72 / 255, green: 85 / 255, blue: 99 / 255),
                                                      Color(red: 41 / 255, green: 50 / 255, blue: 60 / 255)])
    static let darkBackground = Gradient(colors: [Color(#colorLiteral(red: 0.2823529412, green: 0.3333333333, blue: 0.3882352941, alpha: 1)), Color(#colorLiteral(red: 0.1607843137, green: 0.1960784314, blue: 0.2352941176, alpha: 1))])
}
