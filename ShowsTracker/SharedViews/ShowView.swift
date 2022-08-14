//
//  ShowView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 02.05.2022.
//

import SwiftUI

struct ShowView: View {
    
    private let model: Model
    private let itemWidth: CGFloat
    private let tapAction: (Int) -> Void
    
    @State private var isTextTruncated = false
    @State private var isImageLoaded = false
    
    init(model: Model, itemWidth: CGFloat, tapAction: @escaping (Int) -> Void) {
        self.model = model
        self.itemWidth = itemWidth
        self.tapAction = tapAction
    }
    
    var body: some View {
        VStack(spacing: 4) {
            LoadableImageView(path: model.posterPath, isImageLoaded: $isImageLoaded)
                .mask(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    if isImageLoaded {
                        ZStack(alignment: .bottomTrailing) {
                            LinearGradient(
                                gradient: Gradient(colors: [.black, .clear]),
                                startPoint: .bottom,
                                endPoint: .center)
                                .mask(RoundedRectangle(cornerRadius: 8))
                            
                            switch model.accessory {
                            case let .vote(vote):
                                voteAccessoryView(vote: vote)
                            case let .date(day, month):
                                dateAccessoryView(day: day, month: month)
                            }
                        }
                    }
                }
                .frame(width: itemWidth, height: itemWidth * 1.5)
            
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
    
    func voteAccessoryView(vote: String) -> some View {
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
                Text(vote)
                    .font(.medium12)
                    .foregroundColor(.white100)
            }
        }
    }
    
    func dateAccessoryView(day: String, month: String) -> some View {
        ZStack {
            Rectangle()
                .frame(width: 40, height: 34)
                .cornerRadius(8, corners: [.topLeft, .bottomRight])
                .foregroundColor(.text100)
            
            VStack(spacing: 0) {
                Text(day)
                    .font(.bold13Rounded)
                    .foregroundColor(.white100)
                Text(month)
                    .font(.regular11)
                    .foregroundColor(.white100)
            }
        }
    }
}

// MARK: - Model

extension ShowView {
    struct Model: Equatable, Hashable {
        var id: Int = 0
        var posterPath: String = ""
        var name: String = ""
        var accessory: Accessory = .vote("")
        
        enum Accessory: Equatable, Hashable {
            case vote(String)
            case date(day: String, month: String)
        }
    }
}

struct ShowView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ShowView(model: .init(
                posterPath: "/7vjaCdMw15FEbXyLQTVa04URsPm.jpg",
                name: "Леденящие душу приключения Сабрины",
                accessory: .vote("8.2")), itemWidth: 100) { _ in }
                .frame(width: 100, height: 150)
            
            ShowView(model: .init(
                posterPath: "/7vjaCdMw15FEbXyLQTVa04URsPm.jpg",
                name: "Леденящие душу приключения Сабрины",
                accessory: .date(day: "09", month: "Дек")), itemWidth: 100) { _ in }
                .frame(width: 100, height: 150)
        }
    }
}
