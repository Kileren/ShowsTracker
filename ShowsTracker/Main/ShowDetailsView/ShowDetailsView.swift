//
//  ShowDetailsView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 30.05.2021.
//

import SwiftUI
import Resolver

struct ShowDetailsView: View {
    
    @InjectedObject var appState: AppState
    @InjectedObject var interactor: ShowDetailsViewInteractor
    
    var body: some View {
        GeometryReader { geometry in
            if appState.showDetails.isLoaded {
                ZStack(alignment: .top) {
                    blurBackground(geometry: geometry)
                    overlayView(geometry: geometry)
                    
                    VStack(spacing: 0) {
                        imageView(geometry: geometry)
                        spacer(height: 16)
                        mainInfoView
                    }
                }
            } else {
                Rectangle()
                    .foregroundColor(.white100)
            }
        }
        .onAppear {
            interactor.viewAppeared()
        }
    }
    
    func overlayView(geometry: GeometryProxy) -> some View {
        Rectangle()
            .cornerRadius(DesignConst.normalCornerRadius,
                          corners: [.topLeft, .topRight])
            .foregroundColor(.white100)
            .ignoresSafeArea(edges: .bottom)
            .padding(.top, geometry.size.width * 0.62 + 8)
    }
    
    func imageView(geometry: GeometryProxy) -> some View {
        LoadableImageView(path: appState.showDetails.show.posterPath ?? "", width: 500)
            .frame(width: geometry.size.width * 0.4,
                   height: geometry.size.width * 0.62)
            .cornerRadius(DesignConst.normalCornerRadius)
            .padding(.top, 40)
    }
    
    var mainInfoView: some View {
        VStack(spacing: 0) {
            Text(appState.showDetails.show.name ?? "")
                .font(.medium28)
                .foregroundColor(.text100)
            spacer(height: 4)
            Text(appState.showDetails.show.broadcastYears)
                .font(.regular15)
                .foregroundColor(.text60)
            spacer(height: 22)
            
            HStack {
                Spacer()
                ratingView
                Spacer()
                statusView
                Spacer()
                likeView
                Spacer()
            }
        }
    }
    
    var ratingView: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.yellowSoft)
                Text(appState.showDetails.show.vote)
                    .font(.medium17Rounded)
                    .foregroundColor(.yellowSoft)
            }
            Text(appState.showDetails.show.voteCount)
                .font(.medium13)
                .foregroundColor(.text40)
        }
    }
    
    var statusView: some View {
        VStack(spacing: 4) {
            Text(appState.showDetails.show.inProduction == true ? "Продолжается" : "Закончен")
                .font(.medium15)
                .foregroundColor(appState.showDetails.show.inProduction == true ? .greenHard : .redSoft)
            Text("Статус")
                .font(.medium13)
                .foregroundColor(.text40)
        }
    }
    
    var likeView: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .frame(width: 32, height: 32)
            .foregroundColor(.bay)
    }
    
    func blurBackground(geometry: GeometryProxy) -> some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top), content: {
            backgroundImage(geometry: geometry)
            backgroundImageGradient(geometry: geometry)
        })
        .background(
            Color.backgroundLight.edgesIgnoringSafeArea(.all)
        )
    }
    
    func backgroundImage(geometry: GeometryProxy) -> some View {
        LoadableImageView(path: appState.showDetails.show.posterPath ?? "", width: 500)
            .frame(width: geometry.size.width,
                   height: geometry.size.width * 1.335,
                   alignment: .top)
            .ignoresSafeArea(edges: .top)
            .blur(radius: 15)
            .scaleEffect(1.1, anchor: .center)
    }
    
    func backgroundImageGradient(geometry: GeometryProxy) -> some View {
        Rectangle()
            .frame(width: geometry.size.width,
                   height: geometry.size.width * 1.45,
                   alignment: .top)
            .foregroundColor(.clear)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.backgroundLight, Color.backgroundLight.opacity(0)]),
                    startPoint: .bottom,
                    endPoint: .top))
            .ignoresSafeArea(edges: .top)
    }
    
    func spacer(height: CGFloat) -> some View {
        Rectangle()
            .frame(height: height)
            .foregroundColor(.clear)
    }
}

struct ShowDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.registerPreview()
        Resolver.registerViewPreview()
        
        let view = ShowDetailsView()
        view.appState.showDetails.id = 71912
        view.interactor.viewAppeared()
        return view
    }
}

#if DEBUG
fileprivate extension Resolver {
    static func registerViewPreview() {
        register { ShowDetailsViewInteractor() }
    }
}
#endif
