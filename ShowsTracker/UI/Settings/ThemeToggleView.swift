//
//  ThemeToggleView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 02.10.2022.
//

import SwiftUI

struct ThemeToggleView: View {
    
    @Binding var selectedTheme: Theme
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.separators)
                .frame(width: 100, height: 24)
            
            bubbleForSelectedIcon
            
            HStack(spacing: 20) {
                iconView(for: .light)
                iconView(for: .auto)
                iconView(for: .dark)
            }
        }
    }
}

// MARK: - Views

extension ThemeToggleView {
    func iconView(for theme: Theme) -> some View {
        let image: Image
        switch theme {
        case .light:
            image = Image("Icons/Settings/Theme/sun")
        case .dark:
            image = Image("Icons/Settings/Theme/moon")
        case .auto:
            image = Image("Icons/Settings/Theme/settings")
        }
        
        return image
            .renderingMode(.template)
            .foregroundColor(selectedTheme == theme ? .bay : .text40)
//            .background {
//                if theme == selectedTheme {
//                    RoundedRectangle(cornerRadius: 12)
//                        .frame(width: 32, height: 20)
//                        .foregroundColor(.white)
//                }
//            }
            .onTapGesture {
                withAnimation {
                    selectedTheme = theme
                }
            }
    }
    
    var bubbleForSelectedIcon: some View {
        var xOffset: CGFloat {
            switch selectedTheme {
            case .light: return -32
            case .auto: return 0
            case .dark: return 32
            }
        }
        
        return RoundedRectangle(cornerRadius: 12)
            .frame(width: 32, height: 20)
            .foregroundColor(.white)
            .offset(x: xOffset)
    }
}

// MARK: - Models

extension ThemeToggleView {
    enum Theme {
        case light
        case dark
        case auto
    }
}

struct ThemeToggleView_Previews: PreviewProvider {
    
    @State static private var selectedTheme: ThemeToggleView.Theme = .auto
    
    static var previews: some View {
        ThemeToggleView(selectedTheme: $selectedTheme)
    }
}
