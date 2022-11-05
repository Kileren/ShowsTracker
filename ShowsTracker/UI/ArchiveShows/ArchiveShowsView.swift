//
//  ArchiveShowsView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 09.10.2022.
//

import SwiftUI
import Resolver

struct ArchiveShowsView: View {
    
    @InjectedObject private var viewModel: ArchiveShowsViewModel
    @ObservedObject private var sheetNavigator = SheetNavigator()
    
    var body: some View {
        GeometryReader { geometry in
            switch viewModel.model.state {
            case .loading:
                Text("")
            case .empty:
                emptyArchive(geometry: geometry)
            case .shows(let shows):
                ScrollView {
                    showsView(shows: shows, geometry: geometry)
                }
            }
        }
        .padding(.all, 16)
        .navigationTitle(Strings.archive)
        .background {
            Color.dynamic.background.ignoresSafeArea()
        }
        .sheet(
            isPresented: $sheetNavigator.showSheet,
            onDismiss: viewModel.reload,
            content: sheetNavigator.sheetView
        )
        .onAppear { viewModel.onAppear() }
    }
}

private extension ArchiveShowsView {
    func showsView(shows: [ShowView.Model], geometry: GeometryProxy) -> some View {
        gridView(geometry: geometry) { itemWidth in
            ForEach(shows, id: \.id) { model in
                ShowView(model: model, itemWidth: itemWidth) { showID in
                    sheetNavigator.sheetDestination = .showDetails(showID: showID)
                }
            }
        }
    }
    
    func gridView<Content: View>(geometry: GeometryProxy, @ViewBuilder content: @escaping (_ itemWidth: CGFloat) -> Content) -> some View {
        let spacing: CGFloat = 14
        let itemWidth = (geometry.size.width - 2 * spacing) / 3
        return LazyVGrid(
            columns: [
                GridItem(.fixed(itemWidth), spacing: spacing, alignment: .topLeading),
                GridItem(.fixed(itemWidth), spacing: spacing, alignment: .topLeading),
                GridItem(.fixed(itemWidth), spacing: spacing, alignment: .topLeading)
            ],
            alignment: .leading,
            spacing: 16,
            pinnedViews: []) { content(itemWidth) }
    }
    
    func emptyArchive(geometry: GeometryProxy) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 16) {
                Image("Icons/EmptyList")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: geometry.size.width * 0.5,
                           height: geometry.size.width * 0.5)
                    .foregroundColor(.dynamic.text100)
                Text(Strings.emptyArchive)
                    .font(.regular20)
                    .foregroundColor(.dynamic.text100)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, geometry.size.height * 1/5)
            Spacer()
        }
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

struct ArchiveShowsView_Previews: PreviewProvider {
    static var previews: some View {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.dynamic.text100)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.dynamic.text100)]
        return ArchiveShowsView()
    }
}
