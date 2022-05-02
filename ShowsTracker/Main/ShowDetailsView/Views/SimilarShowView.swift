//
//  SimilarShowView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 02.05.2022.
//

import SwiftUI

struct SimilarShowView: View {
    
    private let model: Model
    private let tapAction: (Int) -> Void
    
    init(model: Model, tapAction: @escaping (Int) -> Void) {
        self.model = model
        self.tapAction = tapAction
    }
    
    var body: some View {
        VStack(spacing: 4) {
            LoadableImageView(path: model.posterPath)
                .frame(width: 100, height: 150)
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
            Text(model.name)
                .font(.medium12)
                .foregroundColor(.text100)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 96)
        }
        .onTapGesture {
            tapAction(model.id)
        }
    }
}

// MARK: - Model

extension SimilarShowView {
    struct Model: Equatable, Hashable {
        var id: Int = 0
        var posterPath: String = ""
        var name: String = ""
        var vote: String = ""
    }
}

struct SimilarShowView_Previews: PreviewProvider {
    static var previews: some View {
        SimilarShowView(model: .init(
            posterPath: "/7vjaCdMw15FEbXyLQTVa04URsPm.jpg",
            name: "The Witcher",
            vote: "8.2")) { _ in }
    }
}
