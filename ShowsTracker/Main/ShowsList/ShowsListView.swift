//
//  ShowsListView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 09.05.2022.
//

import Combine
import SwiftUI
import Resolver

struct ShowsListView: View {
    
    @InjectedObject private var viewModel: ShowsListViewModel
    @ObservedObject private var sheetNavigator = SheetNavigator()
    
    @State private var searchedText: String = ""
    
    @State private var filterActive: Bool = false
    @State private var filterIsShown: Bool = false
    
    var body: some View {
        Group {
            if viewModel.model.isLoaded {
                VStack(spacing: 32) {
                    HStack(spacing: 32) {
                        tabView(for: .popular)
                        tabView(for: .soon)
                    }
                    HStack(spacing: 16) {
                        searchView
                        filterButton
                    }
                    GeometryReader { geometry in
                        ScrollView(showsIndicators: false) {
                            switch viewModel.model.currentRepresentation {
                            case .popular:
                                showsView(geometry: geometry)
                            case .upcoming:
                                showsView(geometry: geometry)
                            case .filter:
                                showsView(geometry: geometry)
                            case .search:
                                showsView(geometry: geometry)
                            }
                            
                            STSpacer(height: 16)
                            ProgressView()
                            STSpacer(height: 8)
                        }
                    }
                }
            } else {
                ShowsListSkeletonView()
                    .padding(.top, -8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .overlay {
            if filterActive {
                filterView
            }
        }
        .onAppear { viewModel.viewAppeared() }
        .sheet(isPresented: $sheetNavigator.showSheet) { sheetNavigator.sheetView() }
    }
    
    func tabView(for tab: Model.Tab) -> some View {
        Button {
            viewModel.didSelectTab(tab)
            if tab == .soon, viewModel.model.shows.isEmpty {
                viewModel.getUpcoming()
            }
        } label: {
            Text(tab.name)
                .font(.regular15)
                .foregroundColor(viewModel.model.chosenTab == tab ? .white100 : .text100)
                .frame(height: 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(viewModel.model.chosenTab == tab ? .bay : .clear)
                        .padding(.horizontal, -12)
                        .padding(.vertical, -8)
                )
        }
    }
    
    var searchView: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .frame(height: 48)
                .foregroundColor(.separators)
            
            HStack(spacing: 16) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .padding(.leading, 16)
                
                TextField(
                    "",
                    text: $searchedText,
                    prompt: Text("Поиск").font(.regular17).foregroundColor(.text40)
                )
                    .onSubmit {
                        if !searchedText.isEmpty {
                            viewModel.searchShows(query: searchedText)
                        }
                    }
            }
        }
    }
    
    var filterButton: some View {
        Button {
            filterActive.toggle()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: 32, height: 32)
                    .foregroundColor(viewModel.model.filter.isEmpty ? .white100 : .bay)
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .frame(width: 20, height: 17)
                    .foregroundColor(viewModel.model.filter.isEmpty ? .bay : .white100)
            }
        }
    }
    
    func showsView(geometry: GeometryProxy) -> some View {
        gridView(geometry: geometry) {
            ForEach(viewModel.model.shows, id: \.self) { model in
                ShowView(model: model) { showID in
                    sheetNavigator.sheetDestination = .showDetails(showID: showID)
                    sheetNavigator.showSheet = true
                }
            }
            Rectangle()
                .frame(width: 0, height: 0)
                .foregroundColor(.clear)
                .onAppear {
                    viewModel.getMorePopular()
                    switch viewModel.model.currentRepresentation {
                    case .popular: viewModel.getMorePopular()
                    case .filter: viewModel.getMoreShowsByFilter()
                    case .upcoming: viewModel.getMoreUpcoming()
                    case .search: Logger.log(message: "Load more shows by search")
                    }
                }
        }
    }
    
    func gridView<Content: View>(geometry: GeometryProxy, @ViewBuilder content: () -> Content) -> some View {
        let spacing: CGFloat = 14
        let gridWidth = (geometry.size.width - 2 * spacing) / 3
        return LazyVGrid(
            columns: [
                GridItem(.fixed(gridWidth), spacing: spacing, alignment: .topLeading),
                GridItem(.fixed(gridWidth), spacing: spacing, alignment: .topLeading),
                GridItem(.fixed(gridWidth), spacing: spacing, alignment: .topLeading)
            ],
            alignment: .leading,
            spacing: 16,
            pinnedViews: [],
            content: content)
    }
}

private extension ShowsListView {
    var filterView: some View {
        ZStack {
            Rectangle()
                .foregroundColor(filterIsShown ? .black.opacity(0.25) : .black.opacity(0))
                .animation(.easeInOut, value: filterIsShown)
                .ignoresSafeArea()
                .disableDragging()
                .onTapGesture {
                    filterIsShown = false
                    after(timeout: 0.3) { filterActive = false }
                }
            VStack(spacing: 0) {
                Spacer()
                FilterView(model: viewModel.model.filter, onConfirm: { model in
                    viewModel.filterSelected(model)
                    viewModel.getShowsByFilter()
                    filterIsShown = false
                    after(timeout: 0.3) { filterActive = false }
                }, onClose: {
                    filterIsShown = false
                    after(timeout: 0.3) { filterActive = false }
                })
                .offset(y: filterIsShown ? 0 : 500)
                .animation(.easeInOut, value: filterIsShown)
            }
        }
        .onAppear {
            filterIsShown = true
        }
    }
}

extension ShowsListView {
    struct Model: Equatable {
        var isLoaded: Bool = false
        var chosenTab: Tab = .popular
        var filter: FilterView.Model = .init()
        var currentRepresentation: Representation = .popular
        var shows: [ShowView.Model] = []
        
        enum Representation: Equatable {
            case popular
            case filter
            case upcoming
            case search
        }
        
        enum Tab {
            case popular
            case soon
            
            var name: String {
                switch self {
                case .popular: return "Популярное"
                case .soon: return "Скоро"
                }
            }
        }
    }
}

// MARK: - Sheet Navigator

private class SheetNavigator: ObservableObject {
    
    @Published var showSheet = false
    var sheetDestination: SheetDestination = .none
    
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

struct ShowsListView_Previews: PreviewProvider {
    static var previews: some View {
        ShowsListView()
    }
}
