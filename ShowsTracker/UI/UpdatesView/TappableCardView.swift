//
//  TappableCardView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 26.04.2023.
//

import SwiftUI

struct TappableCardView: View {
    
    @State var isTapped: Bool = false
    @State var backPosterShowed: Bool = false
    @State var posterScale: CGSize = CGSize(width: 1, height: 1)
    @State var posterAngle: Angle = .zero
    @State var posterAxis: (x: CGFloat, y: CGFloat, z: CGFloat) = (0, 0, 0)
    @State var textScale: CGSize = CGSize(width: 0, height: 0)
    @State var textOpacity: Double = 0
    @State var xOffset: CGFloat = 0
    @State var yOffset: CGFloat = 0
    
    private let expandedWidth: CGFloat = 280
    private let containerSize: CGSize = UIApplication.shared.keyWindowScene?.coordinateSpace.bounds.size ?? .zero
    
    let model: Model
    let width: CGFloat
    let onShowInfo: (Int) -> Void
    let onHideInfo: (Int) -> Void
    let onOpenDetails: (Int) -> Void

    var body: some View {
        GeometryReader { card in
            ZStack {
                model.image
                    .resizable()
                    .cornerRadius(16)
                    .scaleEffect(posterScale)
                
                Rectangle()
                    .cornerRadius(16)
                    .foregroundColor(.white100)
                    .opacity(backPosterShowed ? 1 : 0)
                    .shadow(color: .black.opacity(0.15),
                            radius: 4, x: 2, y: 2)
                    .scaleEffect(posterScale)
            }
            .onTapGesture { onTap(card: card) }
            .rotation3DEffect(posterAngle, axis: posterAxis)
            .offset(x: xOffset, y: yOffset)
        }
        .frame(width: width, height: width * 1.5)
        .overlay { textInfo.onTapGesture { onTap(card: nil) } }
    }
    
    var textInfo: some View {
        VStack(spacing: 16) {
            Text(model.title)
                .font(.bold27)
                .foregroundColor(.dynamic.text100)
                .frame(minHeight: 44)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let season = model.season {
                        seasonView(seasonName: season)
                    }
                    seriesView()
                }
            }
            STButton(
                title: Strings.open,
                style: .custom(width: 150, height: 30, font: .regular15)
            ) {
                onOpenDetails(model.id)
            }
        }
        .padding(.all, 16)
        .opacity(backPosterShowed ? 1 : 0)
        .scaleEffect(textScale)
        .opacity(textOpacity)
        .offset(x: xOffset, y: yOffset)
        .frame(width: expandedWidth, height: expandedWidth * 1.5)
    }
    
    func seasonView(seasonName: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Strings.newSeasonOut)
                .foregroundColor(.dynamic.text20)
                .font(.regular15)
            Text(seasonName)
                .foregroundColor(.dynamic.text100)
                .font(.medium17)
        }
    }
    
    func seriesView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Strings.newEpisodesOut)
                .foregroundColor(.dynamic.text20)
                .font(.regular15)
            
            VStack(alignment: .leading, spacing: 2) {
                ForEach(model.episodes, id: \.self) { episode in
                    Text(episode)
                        .foregroundColor(.dynamic.text100)
                        .font(.medium17)
                }
            }
        }
    }
    
    func onTap(card: GeometryProxy?) {
        isTapped.toggle()
        if isTapped {
            onShowInfo(model.id)
            showAnimation(card: card)
        } else {
            onHideInfo(model.id)
            hideAnimation()
        }
    }
    
    func showAnimation(card: GeometryProxy?) {
        guard let card else { return }
        
        let midX = card.frame(in: .global).midX
        let midY = card.frame(in: .global).maxY
        
        withAnimation {
            xOffset = containerSize.width / 2 - midX
            yOffset = containerSize.height / 1.7 - midY
        }
        
        withAnimation(
            Animation
                .easeInOut(duration: 0.5)
        ) {
            posterAngle = isTapped ? .degrees(-180) : .degrees(0)
            posterAxis.y = 1
        }
        
        withAnimation(
            Animation
                .easeInOut(duration: 0.5)
                .delay(0.15)
        ) {
            textScale = .one
        }
        
        withAnimation(
            Animation
                .easeInOut(duration: 0.3)
                .delay(0.25)
        ) {
            textOpacity = 1
        }
        
        withAnimation(
            Animation
                .easeInOut(duration: 0.35)
                .delay(0.25)
        ) {
            let ratio = expandedWidth / width
            self.posterScale = CGSize(width: ratio, height: ratio)
        }
        
        withAnimation(
            Animation
                .easeInOut(duration: 0.0001)
                .delay(0.25)
        ) {
            backPosterShowed = true
        }
    }
    
    func hideAnimation() {
        withAnimation(
            Animation
                .default
                .delay(0.3)
        ) {
            xOffset = 0
            yOffset = 0
        }
        
        withAnimation(
            Animation
                .easeInOut(duration: 0.5)
        ) {
            textScale = .zero
        }
        
        withAnimation(
            Animation
                .easeInOut(duration: 0.3)
        ) {
            textOpacity = 0
        }
        
        withAnimation(
            Animation
                .easeInOut(duration: 0.35)
                .delay(0.05)
        ) {
            self.posterScale = .one
        }
        
        withAnimation(
            Animation
                .easeInOut(duration: 0.5)
                .delay(0.15)
        ) {
            posterAngle = isTapped ? .degrees(-180) : .degrees(0)
            posterAxis.y = 1
        }
        
        withAnimation(
            Animation
                .easeInOut(duration: 0.0001)
                .delay(0.4)
        ) {
            backPosterShowed = false
        }
    }
}

// MARK: - Model

extension TappableCardView {
    struct Model {
        let id: Int
        let image: Image
        let title: String
        let season: String?
        let episodes: [String]
    }
}

struct TappableCardView_Previews: PreviewProvider {
    static var previews: some View {
        let model = TappableCardView.Model(
            id: 0,
            image: Image("TheWitcher"),
            title: "Ведьмак в несколько строчек точно",
            season: "Какое-то долгое название сезона на несколько строчек",
            episodes: [
                "What is Lost",
                "Redanian Intelligence",
                "Turn Your Back"
            ])
        return TappableCardView(
            model: model,
            width: 150,
            onShowInfo: { _ in },
            onHideInfo: { _ in },
            onOpenDetails: { _ in })
    }
}

private extension CGSize {
    static var one = CGSize(width: 1, height: 1)
}
