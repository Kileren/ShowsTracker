//
//  TrackableScrollView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 03.09.2022.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    
    typealias Value = CGFloat
    
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { }
}

struct TrackableScrollView<Content: View>: View {
    
    private let axis: Axis.Set
    private let showIndicators: Bool
    private let content: (GeometryProxy) -> Content
    
    @Binding private var contentOffset: CGFloat
    
    init(axis: Axis.Set = .vertical,
         showIndicators: Bool,
         contentOffset: Binding<CGFloat>,
         content: @escaping (GeometryProxy) -> Content
    ) {
        self.axis = axis
        self.showIndicators = showIndicators
        self._contentOffset = contentOffset
        self.content = content
    }
    
    var body: some View {
        GeometryReader { outsideProxy in
            ScrollView(axis, showsIndicators: showIndicators) {
                ZStack(alignment: axis == .vertical ? .top : .leading) {
                    GeometryReader { insideProxy in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self,
                                        value: self.calculateContentOffset(fromOutsideProxy: outsideProxy, insideProxy: insideProxy))
                    }
                    self.content(outsideProxy)
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { contentOffset = $0 }
        }
    }
    
    private func calculateContentOffset(fromOutsideProxy outsideProxy: GeometryProxy, insideProxy: GeometryProxy) -> CGFloat {
        if axis == .vertical {
            return outsideProxy.frame(in: .global).minY - insideProxy.frame(in: .global).minY
        } else {
            return outsideProxy.frame(in: .global).minX - insideProxy.frame(in: .global).minX
        }
    }
}
