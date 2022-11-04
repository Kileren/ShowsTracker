//
//  ShowsScrollView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 29.10.2022.
//

import SwiftUI

struct ShowsScrollView: View {
    
    @State private var contentOffset: CGFloat = 0
    
    @Binding private var currentCardIndex: Int
    @Binding private var scrollProgress: CGFloat
    
    private let models: [Model]
    
    init(models: [Model], currentCardIndex: Binding<Int>, scrollProgress: Binding<CGFloat>) {
        self.models = models
        self._currentCardIndex = currentCardIndex
        self._scrollProgress = scrollProgress
    }
    
    var body: some View {
        TrackableScrollView(
            axis: .horizontal,
            showIndicators: false,
            contentOffset: $contentOffset
        ) { geometry in
            HStack(spacing: Const.cardsSpacing) {
                ForEach(models, id: \.self) { model in
                    model.image
                        .resizable()
                        .cornerRadius(DesignConst.normalCornerRadius)
                        .frame(width: Const.defaultCardWidth, height: Const.defaultCardHeight)
                        .scaleEffect(scale(for: model))
                        .offset(x: -offset(for: model))
                        .zIndex(-Double(model.index))
                        .onTapGesture { model.tapAction(model.showID) }
                }
                STSpacer(width: Const.defaultCardWidth + Const.cardsSpacing)
            }
            .offset(x: geometry.size.width / 2 - Const.defaultCardWidth / 2)
        }
        .onChange(of: contentOffset) { newValue in
            currentCardIndex = Int((newValue / (Const.defaultCardWidth + Const.cardsSpacing)))
        }
    }
}

// MARK: - Helpers

private extension ShowsScrollView {
    func scale(for model: Model) -> CGFloat {
        let indexOffset = model.index - currentCardIndex
        if indexOffset < 0 { return 1 }
        if indexOffset > 3 { return 0 }
        
        let currentScrollValue = updateCurrentScrollValue()
        if indexOffset == 0 {
            return 1
        } else if indexOffset == 1 {
            return (1 - Const.scaleFirst) * currentScrollValue + Const.scaleFirst
        } else if indexOffset == 2 {
            return (Const.scaleFirst - Const.scaleSecond) * currentScrollValue + Const.scaleSecond
        } else if indexOffset == 3 {
            return (Const.scaleSecond - Const.scaleThird) * currentScrollValue + Const.scaleThird
        } else {
            return 0
        }
    }
    
    func offset(for model: Model) -> CGFloat {
        let indexOffset = model.index - currentCardIndex
        if indexOffset <= 0 { return 0 }
        
        var offsetsOfPreviousCards: CGFloat {
            guard (indexOffset - 1) > 0 else { return 0}
            var result: CGFloat = 0
            for index in 1...(indexOffset - 1) {
                result += Const.offset(index: index)
            }
            return result
        }
        
        let fullLength = Const.defaultCardWidth + Const.cardsSpacing
        let currentScrollValue = updateCurrentScrollValue()
        let currentWidth = Const.defaultCardWidth * scale(for: model)
        let spacing = CGFloat(indexOffset) * Const.cardsSpacing
        let otherCardsWidth = Const.defaultCardWidth * CGFloat(indexOffset - 1)
        let cardLeftLeadingSpace = (Const.defaultCardWidth - currentWidth) / 2
        let offsetForCard = currentWidth - Const.offset(index: indexOffset) * (1 - currentScrollValue)
        return spacing + otherCardsWidth + cardLeftLeadingSpace + offsetForCard - offsetsOfPreviousCards - fullLength * currentScrollValue
    }
    
    func updateCurrentScrollValue() -> CGFloat {
        let fullLength = Const.defaultCardWidth + Const.cardsSpacing
        let passedScroll = fullLength * CGFloat(currentCardIndex)
        let currentScroll = contentOffset - passedScroll
        let value = currentScroll / fullLength
        DispatchQueue.main.async { scrollProgress = value }
        return value
    }
}

// MARK: - Models

extension ShowsScrollView {
    struct Model: Hashable, Equatable {
        let image: Image
        let index: Int
        let showID: Int
        let tapAction: (Int) -> Void
        
        static func == (lhs: ShowsScrollView.Model, rhs: ShowsScrollView.Model) -> Bool {
            lhs.showID == rhs.showID && lhs.index == rhs.index
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(index)
            hasher.combine(showID)
        }
    }
}

// MARK: - Constants

private enum Const {
    static let defaultCardWidth: CGFloat = 182
    static let defaultCardHeight: CGFloat = 280
    static let cardsSpacing: CGFloat = 16
    
    static let scaleFirst = 0.86
    static let scaleSecond = 0.72
    static let scaleThird = 0.57
    
    static func scale(index: Int) -> CGFloat {
        switch index {
        case 1: return 0.86
        case 2: return 0.72
        case 3: return 0.57
        default: return 1
        }
    }
    
    static func offset(index: Int) -> CGFloat {
        switch index {
        case 1: return 40
        case 2: return 32
        case 3: return 20
        default: return 0
        }
    }
}

struct ShowsScrollView_Previews: PreviewProvider {
    @State private static var currentCardIndex: Int = 0
    @State private static var scrollProgress: CGFloat = 0
    
    static var previews: some View {
        ShowsScrollView(models: [
            .init(image: Image("TheWitcher"), index: 0, showID: 0, tapAction: { _ in }),
            .init(image: Image("TheMandalorian"), index: 1, showID: 1, tapAction: { _ in }),
            .init(image: Image("TheWitcher"), index: 2, showID: 2, tapAction: { _ in }),
            .init(image: Image("TheMandalorian"), index: 3, showID: 3, tapAction: { _ in })
        ], currentCardIndex: $currentCardIndex, scrollProgress: $scrollProgress)
    }
}
