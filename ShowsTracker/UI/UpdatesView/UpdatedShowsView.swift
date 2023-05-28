//
//  UpdatedShowsView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 17.04.2023.
//

import SwiftUI

struct UpdatedShowsView: View {
    
    enum PosterSelectionState {
        case none
        case hiding(_ id: Int)
        case specific(_ id: Int)
    }
    
    @State private var posterState: PosterSelectionState = .none
    @ObservedObject private var sheetNavigator = SheetNavigator()
    
    let models: [Model]
    private let maxZIndex = Double(Int.max)
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                STSpacer(height: 24)
                gridView(geometry: geometry) { itemWidth in
                    ForEach(models, id: \.id) { model in
                        TappableCardView(
                            model: model.changes,
                            width: itemWidth,
                            onShowInfo: onShowInfo,
                            onHideInfo: onHideInfo,
                            onOpenDetails: onOpenDetails)
                        .zIndex(zIndexForShow(model.id))
                        .blur(radius: blurForShow(model.id))
                    }
                }
            }
        }
        .background(Color.dynamic.background)
        .sheet(isPresented: $sheetNavigator.showSheet,
               content: sheetNavigator.sheetView)
    }
    
    func zIndexForShow(_ id: Int) -> Double {
        switch posterState {
        case let .specific(posterID), let .hiding(posterID):
            return posterID == id ? maxZIndex : 0
        case .none:
            return 0
        }
    }
    
    func blurForShow(_ id: Int) -> CGFloat {
        if case let .specific(selectedID) = posterState {
            return selectedID == id ? 0 : 3
        }
        return 0
    }
    
    func onShowInfo(_ id: Int) {
        withAnimation { posterState = .specific(id) }
    }
    
    func onHideInfo(_ id: Int) {
        withAnimation { posterState = .hiding(id) }
    }
    
    func onOpenDetails(_ id: Int) {
        sheetNavigator.sheetDestination = .showDetails(showID: id)
    }
}

// MARK: - Views

private extension UpdatedShowsView {
    func cardView(imageName: String, width: CGFloat) -> some View {
        Image(imageName)
            .resizable()
            .frame(width: width, height: width * 1.5)
            .cornerRadius(16)
    }
    
    func gridView<Content: View>(geometry: GeometryProxy, @ViewBuilder content: @escaping (_ itemWidth: CGFloat) -> Content) -> some View {
        let spacing: CGFloat = 14
        let itemWidth = (geometry.size.width - 2 * Const.horizontalPadding - 2 * spacing) / 3
        return LazyVGrid(
            columns: [
                GridItem(.fixed(itemWidth), spacing: spacing, alignment: .topLeading),
                GridItem(.fixed(itemWidth), spacing: spacing, alignment: .center),
                GridItem(.fixed(itemWidth), spacing: spacing, alignment: .topTrailing)
            ],
            alignment: .center,
            spacing: 16,
            pinnedViews: []) { content(itemWidth) }
    }
}

// MARK: - Model

extension UpdatedShowsView {
    struct Model {
        let image: Image
        let id: Int
        let changes: TappableCardView.Model
    }
}

// MARK: - Const

private extension UpdatedShowsView {
    enum Const {
        static let horizontalPadding: CGFloat = 24
    }
}

// MARK: - Sheet Navigator

private class SheetNavigator: ObservableObject {
    
    @Published var showSheet = false
    var sheetDestination: SheetDestination = .none {
        didSet {
            showSheet = true
        }
    }
    
    enum SheetDestination {
        case none
        case showDetails(showID: Int)
    }
    
    func sheetView() -> AnyView {
        switch sheetDestination {
        case .none:
            return AnyView(Text(""))
        case .showDetails(let showID):
            return AnyView(ShowDetailsView(showID: showID))
        }
    }
}

// MARK: - Preview

struct UpdatedShowsView_Previews: PreviewProvider {
    static var previews: some View {
        UpdatedShowsView(models: [
            .init(
                image: Image("TheWitcher"),
                id: 0,
                changes: TappableCardView.Model(
                    id: 0,
                    image: Image("TheWitcher"),
                    title: "The Witcher",
                    season: "Season updates",
                    episodes: [
                        "What is Lost",
                        "Redanian Intelligence",
                        "Turn Your Back"
                    ]
                )
            )
        ])
    }
}
