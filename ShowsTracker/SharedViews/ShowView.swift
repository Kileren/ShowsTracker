//
//  ShowView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 02.05.2022.
//

import SwiftUI

struct ShowView: View {
    
    private let model: Model
    private let tapAction: (Int) -> Void
    
    @State private var isTextTruncated = false
    
    init(model: Model, tapAction: @escaping (Int) -> Void) {
        self.model = model
        self.tapAction = tapAction
    }
    
    var body: some View {
        VStack(spacing: 4) {
            LoadableImageView(path: model.posterPath)
                .mask(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    ZStack(alignment: .bottomTrailing) {
                        LinearGradient(
                            gradient: Gradient(colors: [.black, .clear]),
                            startPoint: .bottom,
                            endPoint: .center)
                            .mask(RoundedRectangle(cornerRadius: 8))
                        
                        ZStack {
                            Rectangle()
                                .frame(width: 42, height: 18)
                                .cornerRadius(8, corners: [.topLeft, .bottomRight])
                                .foregroundColor(.text100)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(.yellowSoft)
                                
                                Text(model.vote)
                                    .font(.medium12)
                                    .foregroundColor(.white100)
                            }
                        }
                    }
                )
            
            ZStack(alignment: .bottom) {
                TruncableText(text: Text(model.name), lineLimit: 2) {
                    isTextTruncated = $0
                }
                .font(.medium12)
                .foregroundColor(.text100)
                .multilineTextAlignment(.center)
                .frame(width: 96)
                
                if isTextTruncated {
                    Rectangle()
                        .frame(width: 96, height: 12, alignment: .center)
                        .foregroundColor(.clear)
                        .background(LinearGradient(gradient: Gradient(colors: [.white40, .white60, .white]), startPoint: .leading, endPoint: .trailing))
                }
            }
        }
        .onTapGesture {
            tapAction(model.id)
        }
    }
}

// MARK: - Model

extension ShowView {
    struct Model: Equatable, Hashable {
        var id: Int = 0
        var posterPath: String = ""
        var name: String = ""
        var vote: String = ""
    }
}

struct ShowView_Previews: PreviewProvider {
    static var previews: some View {
        ShowView(model: .init(
            posterPath: "/7vjaCdMw15FEbXyLQTVa04URsPm.jpg",
            name: "Леденящие душу приключения Сабрины",
            vote: "8.2")) { _ in }
    }
}
