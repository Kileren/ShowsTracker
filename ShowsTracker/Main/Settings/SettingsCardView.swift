//
//  SettingsCardView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 02.10.2022.
//

import SwiftUI

struct SettingsCardView<Content: View>: View {
    
    private let image: Image
    private let title: String
    private let description: String
    private let height: Height
    private let bottomContentView: () -> Content
    
    init(image: Image,
         title: String,
         description: String,
         height: Height = .default,
         @ViewBuilder bottomContentView: @escaping () -> Content) {
        self.image = image
        self.title = title
        self.description = description
        self.height = height
        self.bottomContentView = bottomContentView
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            backgroundView
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    imageView
                    titleView
                }
                descriptionView
                bottomContentView()
            }
            .padding(.all, 8)
        }
        .frame(height: viewHeight)
    }
}

// MARK: - Views

private extension SettingsCardView {
    var backgroundView: some View {
        RoundedRectangle(cornerRadius: 12)
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 4, y: 4)
    }
    
    var imageView: some View {
        Circle()
            .frame(width: 32, height: 32)
            .foregroundColor(.bay.opacity(0.15))
            .overlay {
                image
                    .resizable()
                    .frame(width: 20, height: 20)
            }
    }
    
    var titleView: some View {
        Text(title)
            .font(.medium13)
            .foregroundColor(.text100)
            .lineLimit(2)
            .frame(height: 32)
    }
    
    var descriptionView: some View {
        VStack {
            Text(description)
                .font(.regular10)
                .foregroundColor(.text40)
                .lineLimit(2)
            Spacer()
        }
        .frame(height: 32)
    }
}

// MARK: - Helpers

private extension SettingsCardView {
    var viewHeight: CGFloat? {
        switch height {
        case .default: return 128
        case .exact(let height): return height
        case .flexible: return nil
        }
    }
}

// MARK: - Models

extension SettingsCardView {
    enum Height {
        case `default`
        case exact(height: CGFloat)
        case flexible
    }
}

struct SettingsCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCardView(
            image: Image("Icons/Settings/cloud"),
            title: Strings.iCloudSync,
            description: Strings.actualInfoOnAllDevices) {
                Text("123")
            }
        .frame(width: 163)
    }
}
