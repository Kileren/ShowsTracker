//
//  PagingScrollView.swift
//  ShowsTracker
//
//  Created by s.bogachev on 29.01.2021.
//

import SwiftUI

struct PagingScrollView<Content: View & Identifiable>: View {
    
    @State private var offset: CGFloat = 0
    @State private var progress: CGFloat = 0
    @State var index: Int = 0
    
    let content: [Content]
    let spacing: CGFloat
    let changeIndexClosure: (Int) -> Void
    let changeProgressClosure: (CGFloat) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            return ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: spacing) {
                    ForEach(content) { view in
                        view.frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
            .content
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        onChanged(value: value, geometry: geometry)
                    }
                    .onEnded { value in
                        onEnded(value: value, geometry: geometry)
                    }
            )
            .onAppear {
                offset = -geometry.size.width * CGFloat(index)
            }
        }
    }
    
    func onChanged(value: DragGesture.Value, geometry: GeometryProxy) {
        offset = value.translation.width - CGFloat(index) * (geometry.size.width + spacing)
        progress = -offset / (geometry.size.width + spacing)
        changeProgressClosure(progress)
    }
    
    func onEnded(value: _ChangedGesture<DragGesture>.Value, geometry: GeometryProxy) {
        if -value.predictedEndTranslation.width > geometry.size.width / 2, index < content.count - 1 {
            index += 1
            changeIndexClosure(index)
        } else if value.predictedEndTranslation.width > geometry.size.width / 2, index > 0 {
            index -= 1
            changeIndexClosure(index)
        } else {
            changeProgressClosure(CGFloat(index))
        }
        
        withAnimation {
            offset = -geometry.size.width * CGFloat(index) - CGFloat(index) * spacing
        }
    }
}

struct PagingScrollView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            PagingScrollView(
                index: 0,
                content: (0...3).map { index in ViewForPreview() },
                spacing: 32,
                changeIndexClosure: { _ in },
                changeProgressClosure: { _ in }
            )
            .frame(width: geometry.size.width * 0.6,
                   height: geometry.size.width * 0.9)
            .padding(.leading, geometry.size.width * 0.2)
        }
    }
}

fileprivate struct ViewForPreview: View, Identifiable {
    var id = UUID()
    
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.blue)
        }
    }
}
