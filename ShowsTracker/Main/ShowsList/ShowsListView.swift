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
    
    @InjectedObject private var appState: AppState
    @Injected private var interactor: ShowsListViewInteractor
    
    @State private var model: Model = .init()
    @State private var searchedText: String = ""
    
    @State private var filterActive: Bool = false
    @State private var filterIsShown: Bool = false
    
    @State private var detailsShown: Bool = false
    
    var body: some View {
        Group {
            if model.isLoaded {
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
                            switch model.currentRepresentation {
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
        .onAppear { interactor.viewAppeared() }
        .onReceive(modelUpdate) { model = $0 }
        .sheet(isPresented: $detailsShown) { ShowDetailsView() }
    }
    
    func tabView(for tab: Model.Tab) -> some View {
        Button {
            interactor.didSelectTab(tab)
            if tab == .soon, model.shows.isEmpty {
                interactor.getUpcoming()
            }
        } label: {
            Text(tab.name)
                .font(.regular15)
                .foregroundColor(model.chosenTab == tab ? .white100 : .text100)
                .frame(height: 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(model.chosenTab == tab ? .bay : .clear)
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
                            interactor.searchShows(query: searchedText)
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
                    .foregroundColor(model.filter.isEmpty ? .white100 : .bay)
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .frame(width: 20, height: 17)
                    .foregroundColor(model.filter.isEmpty ? .bay : .white100)
            }
        }
    }
    
    func showsView(geometry: GeometryProxy) -> some View {
        gridView(geometry: geometry) {
            ForEach(model.shows, id: \.self) { model in
                ShowView(model: model) { showID in
                    appState.routing.value.showDetails.showID = showID
                    detailsShown = true
                }
            }
            Rectangle()
                .frame(width: 0, height: 0)
                .foregroundColor(.clear)
                .onAppear {
                    interactor.getMorePopular()
                    switch model.currentRepresentation {
                    case .popular: interactor.getMorePopular()
                    case .filter: interactor.getMoreShowsByFilter()
                    case .upcoming: interactor.getMoreUpcoming()
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
                FilterView(model: model.filter, onConfirm: { model in
                    interactor.filterSelected(model)
                    interactor.getShowsByFilter()
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
    var modelUpdate: AnyPublisher<Model, Never> {
        appState.info.updates(for: \.showsList)
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

struct ShowsListView_Previews: PreviewProvider {
    static var previews: some View {
        ShowsListView()
    }
}
