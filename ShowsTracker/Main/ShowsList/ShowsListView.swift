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
                            popularShows(geometry: geometry)
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
        .onAppear { interactor.viewAppeared() }
        .onReceive(modelUpdate) { model = $0 }
        .sheet(isPresented: $detailsShown) { ShowDetailsView() }
    }
    
    func tabView(for tab: Model.Tab) -> some View {
        Button {
            model.chosenTab = tab
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
                    .foregroundColor(filterActive ? .bay : .white100)
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(filterActive ? .white100 : .bay)
            }
        }
    }
    
    func popularShows(geometry: GeometryProxy) -> some View {
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
            pinnedViews: []) {
                ForEach(model.popularShows, id: \.self) { model in
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
                    }
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
        var popularShows: [ShowView.Model] = []
        
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
