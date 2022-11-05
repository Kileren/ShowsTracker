//
//  PageDotsView.swift
//  ShowsTracker
//
//  Created by s.bogachev on 01.02.2021.
//

import SwiftUI

struct PageDotsView: View {
    
    // MARK: - Public
    
    let numberOfPages: Int
    let currentIndex: Int
    
    // MARK: - State
    
    private let circleSize: CGFloat = 12
    private let circleSpacing: CGFloat = 8
    
    private let primaryColor: Color = .dynamic.bay
    private let secondaryColor: Color = .dynamic.text20
    
    private let smallScale: CGFloat = 0.84
    private let scale: CGFloat = 0.16
    
    // MARK: - View
    
    var body: some View {
        HStack(spacing: circleSpacing) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                if shouldShowIndex(index) {
                    Circle()
                        .fill(currentIndex == index ? primaryColor : secondaryColor)
                        .scaleEffect(scaleEffect(index: index))
                        .frame(width: circleSize, height: circleSize)
                        .transition(AnyTransition.opacity.combined(with: .scale))
                        .id(index)
                }
            }
        }
    }
    
    func shouldShowIndex(_ index: Int) -> Bool {
        ((currentIndex - 3)...(currentIndex + 3)).contains(index)
    }
    
    func scaleEffect(index: Int) -> CGFloat {
        guard currentIndex != index else { return 1 }
        return 1 - CGFloat(abs(currentIndex - index)) * scale
    }
}

struct PageDotsView_Previews: PreviewProvider {
    static var previews: some View {
        PageDotsView(numberOfPages: 4, currentIndex: 0)
    }
}
