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
    
    @StateObject private var viewModel = ShowsListViewModel()
    @ObservedObject private var sheetNavigator = SheetNavigator()
    
    @State private var searchedText: String = ""
    
    @State private var filterActive: Bool = false
    @State private var filterIsShown: Bool = false
    
    var body: some View {
        ZStack {
            if viewModel.model.initiallyLoaded {
                VStack(spacing: 32) {
                    if viewModel.model.tabIsVisible {
                        HStack(spacing: 32) {
                            tabView(for: .popular)
                            tabView(for: .soon)
                        }
                    }
                    HStack(spacing: 16) {
                        searchView
                        if viewModel.model.filterButtonIsVisible {
                            filterButton
                        }
                    }
                    
                    switch viewModel.model.state {
                    case .loading:
                        VStack {
                            STSpinner()
                            Spacer()
                        }
                    case .error:
                        errorViewOnLoading
                    case .loaded:
                        contentView(shows: viewModel.model.shows,
                                    loadMoreAvailable: viewModel.model.loadMoreAvailable)
                    }
                }
            } else {
                ShowsListSkeletonView()
                    .padding(.top, -8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .background(Color.dynamic.background)
        .overlay {
            if filterActive {
                filterView
            }
        }
        .onAppear { viewModel.viewAppeared() }
        .sheet(isPresented: $sheetNavigator.showSheet) { sheetNavigator.sheetView() }
    }
    
    func tabView(for tab: ShowsListModel.Tab) -> some View {
        Button {
            viewModel.didSelectTab(tab)
        } label: {
            Text(tab.name)
                .font(.regular15)
                .foregroundColor(viewModel.model.chosenTab == tab ? .white100 : .dynamic.text100)
                .frame(height: 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(viewModel.model.chosenTab == tab ? .dynamic.bay : .clear)
                        .padding(.horizontal, -12)
                        .padding(.vertical, -8)
                )
        }
    }
    
    var searchView: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .frame(height: 48)
                .foregroundColor(.dynamic.separators)
            
            HStack(spacing: 16) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .padding(.leading, 16)
                    .foregroundColor(.dynamic.text100)
                
                TextField(
                    "",
                    text: $searchedText,
                    prompt: Text(Strings.search).font(.regular17).foregroundColor(.dynamic.text40)
                )
                .foregroundColor(.dynamic.text100)
                .onSubmit {
                    viewModel.searchShows(query: searchedText)
                }
                
                if !searchedText.isEmpty {
                    Button {
                        searchedText = ""
                        if case .search = viewModel.model.currentRepresentation {
                            viewModel.searchShows(query: "")
                        }
                    } label: {
                        Text(Strings.clear)
                            .font(.medium12)
                            .foregroundColor(.dynamic.text40)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(height: 24)
                                    .foregroundColor(Color(light: .graySimple, dark: .backgroundDarkEl1))
                                    .padding(.horizontal, -8)
                            )
                    }
                    STSpacer(width: 8)
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
                    .foregroundColor(viewModel.model.filter.isEmpty ? .clear : .dynamic.bay)
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .frame(width: 20, height: 17)
                    .foregroundColor(viewModel.model.filter.isEmpty ? .dynamic.bay : .white100)
            }
        }
    }
    
    func contentView(shows: [ShowView.Model], loadMoreAvailable: Bool) -> some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollReader in
                ScrollView(showsIndicators: false) {
                    Rectangle().frame(width: 0, height: 0).id("topView")
                    
                    if !shows.isEmpty {
                        showsView(shows: shows,
                                  loadMoreSpinnerIsVisible: loadMoreAvailable,
                                  geometry: geometry)
                    } else if !loadMoreAvailable {
                        STSpacer(height: geometry.size.height / 4)
                        HStack {
                            Spacer()
                            Text(Strings.emptySearchResult)
                                .font(.regular17)
                                .foregroundColor(.dynamic.text100)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                            Spacer()
                        }
                    }
                    
                    STSpacer(height: 16)
                    
                    if loadMoreAvailable {
                        HStack {
                            Spacer()
                            STSpinner()
                            Spacer()
                        }
                        STSpacer(height: 8)
                    }
                }
                .onChange(of: viewModel.model.currentRepresentation) { representation in
                    var timeout: TimeInterval {
                        switch representation {
                        case .filter, .search: return 0.1
                        default: return 0.05
                        }
                    }
                    after(timeout: timeout) {
                        withAnimation {
                            scrollReader.scrollTo("topView")
                        }
                    }
                }
            }
        }
    }
    
    func showsView(
        shows: [ShowView.Model],
        loadMoreSpinnerIsVisible: Bool,
        geometry: GeometryProxy
    ) -> some View {
        gridView(geometry: geometry) { itemWidth in
            ForEach(shows, id: \.id) { model in
                ShowView(model: model, itemWidth: itemWidth) { showID in
                    sheetNavigator.sheetDestination = .showDetails(showID: showID)
                }
            }
            
            if loadMoreSpinnerIsVisible {
                Rectangle()
                    .frame(width: 0, height: 0)
                    .foregroundColor(.clear)
                    .onAppear { viewModel.getMore() }
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
    
    var errorViewOnLoading: some View {
        VStack(spacing: 16) {
            Text(Strings.errorOccured)
                .font(.regular17)
                .foregroundColor(.text100)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            STButton(title: Strings.retry,
                     style: .medium,
                     action: viewModel.retryAfterError)
            Spacer()
        }
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
                    defer {
                        filterIsShown = false
                        after(timeout: 0.3) { filterActive = false }
                    }
                    guard viewModel.model.filter != model else { return }
                    viewModel.filterSelected(model)
                    viewModel.getShowsByFilter()
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

struct ShowsListView_Previews: PreviewProvider {
    static var previews: some View {
        ShowsListView()
    }
}

