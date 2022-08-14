//
//  TabBarView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 27.01.2022.
//

import Combine
import SwiftUI
import Resolver

struct TabBarView: View {

    @Environment(\.isPreview) var isPreview

    let geometry: GeometryProxy
    
    @State private var model: Model = .init()
    private let showsView: ShowsView = ShowsView()

    var body: some View {
        VStack(spacing: 0) {
            selectedView
            HStack(alignment: .center, spacing: spacing) {
                button(for: .shows)
                button(for: .movies)
                button(for: .profile)
            }
            .frame(width: geometry.size.width, height: 60)
            .background(Color.white100)
        }
    }

    var selectedView: some View {
        if isPreview {
            return AnyView(EmptyView())
        } else {
            switch model.selectedTab {
            case .shows:
                return AnyView(showsView)
            case .movies:
                return AnyView(ShowsView())
            case .profile:
                return AnyView(ShowsView())
            }
        }
    }

    func button(for value: Model.Tab) -> some View {
        Button {
            model.selectedTab = value
        } label: {
            Image(value.imageName)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(model.selectedTab == value ? Color.bay : Color.text100)
        }
    }
}

// MARK: - Helpers

private extension TabBarView {
    var spacing: CGFloat {
        (geometry.size.width - 2 * Constants.horizontalPadding - CGFloat(Constants.numberOfItems) * Constants.iconSize.width) / CGFloat((Constants.numberOfItems - 1))
    }
}

// MARK: - Model

extension TabBarView {
    struct Model: Equatable {
        var selectedTab: Tab = .shows
        
        enum Tab: Equatable {
            case shows
            case movies
            case profile
            
            var imageName: String {
                switch self {
                case .shows: return "Icons/TabBar/tv"
                case .movies: return "Icons/TabBar/movies"
                case .profile: return "Icons/TabBar/profile"
                }
            }
        }
    }
}

// MARK: - Constants

private extension TabBarView {
    enum Constants {
        static let iconSize = CGSize(width: 32, height: 32)
        static let horizontalPadding: CGFloat = 42
        static let numberOfItems: Int = 3
    }
}

// MARK: - Preview

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        return GeometryReader { reader in
            TabBarView(geometry: reader)
        }
    }
}

#if DEBUG
struct EmptyView: View {

    var body: some View {
        Color.bay
    }
}
#endif
