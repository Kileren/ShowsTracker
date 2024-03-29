//
//  LikedShowsListView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 31.10.2022.
//

import SwiftUI
import Resolver

struct LikedShowsListView: View {
    
    @StateObject private var viewModel = LikedShowsListViewModel()
    @ObservedObject private var sheetNavigator = SheetNavigator()
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var editMode: EditMode = .inactive
    
    private var isEditModeActive: Bool {
        editMode == .active
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.model.shows) {
                    showView(show: $0)
                }
                .onMove { indexSet, index in
                    viewModel.moveShow(indexSet: indexSet, index: index)
                    viewModel.model.shows
                        .move(fromOffsets: indexSet, toOffset: index)
                }
                .onDelete { indexSet in
                    viewModel.delete(indexSet: indexSet)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(.plain)
            .background(Color.dynamic.background)
            .navigationTitle(Strings.yourShows)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.close) { dismiss.callAsFunction() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditModeActive ? Strings.done : Strings.edit) {
                        withAnimation {
                            editMode = isEditModeActive ? .inactive : .active
                        }
                    }
                }
            }
            .environment(\.editMode, $editMode)
        }
        .sheet(isPresented: $sheetNavigator.showSheet,
               onDismiss: viewModel.reload,
               content: sheetNavigator.sheetView)
        .onAppear(perform: viewModel.viewAppeared)
    }
    
    func showView(show: FavoritesShowsListModel.Show) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.dynamic.separators)
                .frame(height: 80)
            
            HStack(spacing: 12) {
                show.image
                    .resizable()
                    .frame(width: 40, height: 64)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(show.title)
                        .font(.medium17Rounded)
                        .foregroundColor(.dynamic.text100)
                        .lineLimit(1)
                    Text(show.description)
                        .font(.medium13Rounded)
                        .foregroundColor(.dynamic.text40)
                }
                
                if editMode != .active {
                    Spacer()
                    Image(systemName: "list.dash")
                        .foregroundColor(.dynamic.bay)
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
        }
        .onTapGesture {
            sheetNavigator.sheetDestination = .showDetails(showID: show.id)
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

struct LikedShowsListView_Previews: PreviewProvider {
    static var previews: some View {
        LikedShowsListView()
    }
}
