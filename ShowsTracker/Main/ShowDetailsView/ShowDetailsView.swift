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
            if interactor.showIsLoaded {
                ZStack(alignment: .top) {
                    blurBackground(geometry: geometry)
                    overlayView(geometry: geometry)
                    imageView(geometry: geometry)
                }
            } else {
                Rectangle()
                    .foregroundColor(.white100)
            }
        }
        .onAppear { interactor.viewAppeared() }
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
        interactor.show.image
            .resizable()
            .frame(width: geometry.size.width * 0.4,
                   height: geometry.size.width * 0.62)
            .cornerRadius(DesignConst.normalCornerRadius)
            .padding(.top, 40)
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
        interactor.show.image
            .resizable()
            .frame(width: geometry.size.width,
                   height: geometry.size.width * 1.335,
                   alignment: .top)
            .ignoresSafeArea(edges: .top)
            .blur(radius: 15)
            .scaleEffect(CGSize(width: 1.05, height: 1.05))
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
}

struct ShowDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.registerPreview()
        Resolver.registerViewPreview()
        
        let view = ShowDetailsView()
        view.interactor.viewAppeared()
        return view
    }
}

#if DEBUG
fileprivate extension Resolver {
    static func registerViewPreview() {
        let detailedShow = DetailedShow(imageData: UIImage(named: "TheWitcher")?.pngData())
        let input = ShowDetailsView.Input.detailed(show: detailedShow)
        
        register { ShowDetailsViewInteractor(appState: resolve(), input: input) }
        register { ImageLoader() }
    }
}
#endif
