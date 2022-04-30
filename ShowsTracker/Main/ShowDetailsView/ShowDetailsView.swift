//
//  ShowDetailsView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 30.05.2021.
//

import Combine
import SwiftUI
import Resolver

struct ShowDetailsView: View {
    
    @InjectedObject var appState: AppState
    @InjectedObject var interactor: ShowDetailsViewInteractor
    
    @State private var model: Model = Model()
    
    var body: some View {
        GeometryReader { geometry in
            if model.isLoaded {
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
        .onReceive(modelUpdates) { self.model = $0 }
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
        LoadableImageView(path: model.posterPath, width: 500)
            .frame(width: geometry.size.width * 0.4,
                   height: geometry.size.width * 0.62)
            .cornerRadius(DesignConst.normalCornerRadius)
            .padding(.top, 40)
    }
    
    var mainInfoView: some View {
        VStack(spacing: 0) {
            Text(model.name)
                .font(.medium28)
                .foregroundColor(.text100)
            spacer(height: 4)
            Text(model.broadcastYears)
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
                Text(model.vote)
                    .font(.medium17Rounded)
                    .foregroundColor(.yellowSoft)
            }
            Text(model.voteCount)
                .font(.medium13)
                .foregroundColor(.text40)
        }
    }
    
    var statusView: some View {
        VStack(spacing: 4) {
            Text(model.inProduction ? "Продолжается" : "Закончен")
                .font(.medium15)
                .foregroundColor(model.inProduction ? .greenHard : .redSoft)
            Text("Статус")
                .font(.medium13)
                .foregroundColor(.text40)
        }
    }
    
    var likeView: some View {
        Button {
            interactor.didTapLikeButton()
        } label: {
            Image(systemName: model.isLiked ? "heart.fill" : "heart")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.bay)
        }
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
        LoadableImageView(path: model.posterPath, width: 500)
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

// MARK: - State Updates

extension ShowDetailsView {
    
    var modelUpdates: AnyPublisher<Model, Never> {
        let showID = appState.routing.value.showDetails.showID
        if appState.info[\.showDetails[showID]] == nil {
            appState.info[\.showDetails[showID]] = .init()
        }
        return appState.info.updates(for: \.showDetails[showID])
    }
    
    var routingUpdates: AnyPublisher<Routing, Never> {
        appState.routing.updates(for: \.showDetails)
    }
}

// MARK: - Routing

extension ShowDetailsView {
    struct Routing: Equatable {
        var showID: Int = 0
    }
}

// MARK: - Model

extension ShowDetailsView {
    struct Model: Equatable {
        var isLoaded = false
        var posterPath = ""
        var name = ""
        var broadcastYears = ""
        var vote = ""
        var voteCount = ""
        var inProduction = true
        var isLiked = true
    }
}

struct ShowDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.registerPreview()
        Resolver.registerViewPreview()
        
        let view = ShowDetailsView()
        view.appState.routing.value.showDetails.showID = 71912
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
