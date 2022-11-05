//
//  ThemeToggleView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 02.10.2022.
//

import SwiftUI

struct ThemeToggleView: View {
    
    @Binding var selectedTheme: AppTheme
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.dynamic.separators)
                .frame(width: 100, height: 24)
            
            bubbleForSelectedIcon
            
            HStack(spacing: 20) {
                iconView(for: .light)
                iconView(for: .unspecified)
                iconView(for: .dark)
            }
        }
    }
}

// MARK: - Views

extension ThemeToggleView {
    func iconView(for theme: AppTheme) -> some View {
        let image: Image
        switch theme {
        case .light:
            image = Image("Icons/Settings/Theme/sun")
        case .dark:
            image = Image("Icons/Settings/Theme/moon")
        case .unspecified:
            image = Image("Icons/Settings/Theme/settings")
        }
        
        return image
            .renderingMode(.template)
            .foregroundColor(selectedTheme == theme ? .dynamic.bay : .dynamic.text40)
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
            case .unspecified: return 0
            case .dark: return 32
            }
        }
        
        return RoundedRectangle(cornerRadius: 12)
            .frame(width: 32, height: 20)
            .foregroundColor(.dynamic.backgroundEl1)
            .offset(x: xOffset)
    }
}

struct ThemeToggleView_Previews: PreviewProvider {
    
    @State static private var selectedTheme: AppTheme = .unspecified
    
    static var previews: some View {
        ThemeToggleView(selectedTheme: $selectedTheme)
    }
}
