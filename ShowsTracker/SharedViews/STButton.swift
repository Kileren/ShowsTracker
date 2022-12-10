//
//  STButton.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 17.04.2021.
//

import SwiftUI

struct STButton: View {
    
    // MARK: - Models
    
    enum Style {
        case small(width: Width)
        case medium
        case normal
        case custom(width: CGFloat, height: CGFloat, font: Font)
    }
    
    enum Width {
        case fit
        case fixed(CGFloat)
    }
    
    // MARK: - State
    
    let title: String
    let style: Style
    let animating: Binding<Bool>?
    let action: () -> Void
    
    @State private var scale: CGFloat = 1
    
    init(title: String,
         style: Style,
         animating: Binding<Bool>? = nil,
         action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.animating = animating
        self.action = action
    }
    
    // MARK: - Views
    
    var body: some View {
        Button {
            action()
        } label: {
            if isAnimating {
                spinner.background(background)
            } else {
                text.background(background)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isAnimating)
    }
    
    @ViewBuilder
    var text: some View {
        switch style {
        case .small(let width):
            switch width {
            case .fit:
                Text(title)
                    .font(.regular13)
                    .foregroundColor(.white100)
                    .padding(.horizontal, 24)
                    .frame(height: 24)
            case .fixed(let width):
                Text(title)
                    .font(.regular13)
                    .foregroundColor(.white100)
                    .frame(width: width, height: 24)
            }
        case .medium:
            Text(title)
                .font(.regular17)
                .foregroundColor(.white100)
                .padding(.horizontal, 24)
                .frame(height: 40)
        case .normal:
            Text(title)
                .font(.regular20)
                .foregroundColor(.white100)
                .frame(width: 300, height: 50)
        case let .custom(width, height, font):
            Text(title)
                .font(font)
                .foregroundColor(.white100)
                .frame(width: width, height: height)
        }
    }
    
    var spinner: some View {
        var height: CGFloat {
            switch style {
            case .small: return 24
            case .medium: return 40
            case .normal: return 50
            case .custom(_, let height, _): return height
            }
        }
        return STSpinner().frame(height: height)
    }
    
    @ViewBuilder
    var background: some View {
        let foregroundColor: Color = isAnimating ?
            .dynamic.separators :
            .dynamic.bay
        switch style {
        case .small(let width):
            switch width {
            case .fit:
                RoundedRectangle(cornerRadius: 15)
                    .frame(height: 24)
                    .foregroundColor(foregroundColor)
                    .padding(.horizontal, -24)
            case .fixed(let width):
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: width, height: 24)
                    .foregroundColor(foregroundColor)
            }
        case .medium:
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 40)
                .foregroundColor(foregroundColor)
                .padding(.horizontal, -24)
        case .normal:
            RoundedRectangle(cornerRadius: 16)
                .frame(width: 300, height: 50)
                .foregroundColor(foregroundColor)
                .padding(.horizontal, -24)
        case let .custom(width, height, _):
            RoundedRectangle(cornerRadius: 16)
                .frame(width: width, height: height)
                .foregroundColor(foregroundColor)
        }
    }
}

private extension STButton {
    var isAnimating: Bool {
        animating?.wrappedValue == true
    }
}

struct STButton_Previews: PreviewProvider {
    @State static var animating: Bool = true
    
    static var previews: some View {
        Group {
            STButton(title: Strings.add,
                     style: .small(width: .fit),
                     action: { })
            STButton(title: Strings.add,
                     style: .small(width: .fixed(150)),
                     action: { })
            STButton(title: Strings.add,
                     style: .normal,
                     action: { })
            STButton(title: Strings.add,
                     style: .normal,
                     animating: Self.$animating,
                     action: { })
        }
    }
}
