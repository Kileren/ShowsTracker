//
//  UpdatesLoadingView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 28.05.2023.
//

import SwiftUI

struct UpdatesLoadingView: View {
    var body: some View {
        STSpacer(height: 24)
        GeometryReader { geometry in
            gridView(geometry: geometry) { itemWidth in
                cardView(width: itemWidth)
                cardView(width: itemWidth)
                cardView(width: itemWidth)
                cardView(width: itemWidth)
            }
            .foregroundColor(.dynamic.separators)
            .redacted(reason: .shimmer)
        }
    }
}

// MARK: - Views

private extension UpdatesLoadingView {
    func cardView(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .frame(width: width, height: width * 1.5)
    }
    
    func gridView<Content: View>(geometry: GeometryProxy, @ViewBuilder content: @escaping (_ itemWidth: CGFloat) -> Content) -> some View {
        let spacing: CGFloat = 14
        let itemWidth = (geometry.size.width - 2 * Const.horizontalPadding - 2 * spacing) / 3
        return LazyVGrid(
            columns: [
                GridItem(.fixed(itemWidth), spacing: spacing, alignment: .topLeading),
                GridItem(.fixed(itemWidth), spacing: spacing, alignment: .center),
                GridItem(.fixed(itemWidth), spacing: spacing, alignment: .topTrailing)
            ],
            alignment: .center,
            spacing: 16,
            pinnedViews: []) { content(itemWidth) }
    }
}

// MARK: - Const

private extension UpdatesLoadingView {
    enum Const {
        static let horizontalPadding: CGFloat = 24
    }
}

// MARK: - Preview

struct UpdatesLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        UpdatesLoadingView()
    }
}
