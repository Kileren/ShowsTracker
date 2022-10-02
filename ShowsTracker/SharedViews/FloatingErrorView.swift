//
//  FloatingErrorView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 17.09.2022.
//

import SwiftUI

struct FloatingErrorView: View {
    
    enum State {
        case hidden
        case shown
        
        static let animation: Animation = .interactiveSpring(
            response: 0.3,
            dampingFraction: 0.55
        )
    }
        
    let icon: Image?
    let text: String
    
    @Binding var state: State
    
    var body: some View {
        GeometryReader { geometry in
            HStack() {
                Spacer()
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: geometry.size.width - 48, height: Const.height)
                    .foregroundColor(.text100)
                    .overlay {
                        HStack(spacing: 16) {
                            if let icon = icon {
                                icon
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white100)
                            }
                            Text(text)
                                .foregroundColor(.white100)
                                .font(.medium17)
                        }
                    }
                Spacer()
            }
            .offset(y: offset(geometry: geometry))
            .onChange(of: state) { newValue in
                guard newValue == .shown else { return }
                after(timeout: 1.5) {
                    if state == .shown && !Task.isCancelled {
                        withAnimation(State.animation) {
                            state = .hidden
                        }
                    }
                }
            }
        }
    }
}

private extension FloatingErrorView {
    func offset(geometry: GeometryProxy) -> CGFloat {
        if state == .hidden {
            return geometry.size.height + geometry.safeAreaInsets.bottom
        } else {
            return geometry.size.height - Const.height - 24
        }
    }
}

private extension FloatingErrorView {
    enum Const {
        static let height: CGFloat = 48
    }
}

struct FloatingErrorView_Previews: PreviewProvider {
    
    @State static var state: FloatingErrorView.State = .shown
    
    static var previews: some View {
        FloatingErrorView(
            icon: Image(systemName: "xmark.circle.fill"),
            text: "Описания пока нет",
            state: $state
        )
    }
}
