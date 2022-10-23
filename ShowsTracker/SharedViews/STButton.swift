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
        case normal(geometry: GeometryProxy)
    }
    
    enum Width {
        case fit
        case fixed(CGFloat)
    }
    
    // MARK: - State
    
    let title: String
    let style: Style
    let action: () -> Void
    
    @State private var scale: CGFloat = 1
    
    // MARK: - Views
    
    var body: some View {
        Button {
            action()
        } label: {
            text
        }
        .buttonStyle(ScaleButtonStyle())
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
                    .background(background)
                    .padding(.horizontal, 24)
                    .frame(height: 24)
            case .fixed(let width):
                Text(title)
                    .font(.regular13)
                    .foregroundColor(.white100)
                    .background(background)
                    .frame(width: width, height: 24)
            }
        case .medium:
            Text(title)
                .font(.regular17)
                .foregroundColor(.white100)
                .background(background)
                .padding(.horizontal, 24)
                .frame(height: 40)
        case .normal(let geometry):
            Text(title)
                .font(.regular20)
                .foregroundColor(.white100)
                .background(background)
                .frame(width: min(geometry.size.width - 48, 300),
                       height: 50)
        }
    }
    
    @ViewBuilder
    var background: some View {
        switch style {
        case .small(let width):
            switch width {
            case .fit:
                RoundedRectangle(cornerRadius: 15)
                    .frame(height: 24)
                    .foregroundColor(.bay)
                    .padding(.horizontal, -24)
            case .fixed(let width):
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: width, height: 24)
                    .foregroundColor(.bay)
            }
        case .medium:
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 40)
                .foregroundColor(.bay)
                .padding(.horizontal, -24)
        case .normal(let geometry):
            RoundedRectangle(cornerRadius: 16)
                .frame(width: min(geometry.size.width - 48, 300),
                       height: 50)
                .foregroundColor(.bay)
                .padding(.horizontal, -24)
        }
    }
}

struct STButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GeometryReader { geometry in
                STButton(title: Strings.add,
                         style: .small(width: .fit),
                         action: { })
            }
            
            GeometryReader { geometry in
                STButton(title: Strings.add,
                         style: .small(width: .fixed(150)),
                         action: { })
            }
            
            GeometryReader { geometry in
                STButton(title: Strings.add,
                         style: .normal(geometry: geometry),
                         action: { })
            }
        }
        .previewLayout(.fixed(width: 400, height: 70))
    }
}
