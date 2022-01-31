//
//  TabBarView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 27.01.2022.
//

import SwiftUI
import Resolver

struct TabBarView: View {

    @InjectedObject var appState: AppState

    @Environment(\.isPreview) var isPreview

    let geometry: GeometryProxy
    
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
            switch appState.selectedTabBarView {
            case .shows:
                return AnyView(showsView)
            case .movies:
                return AnyView(ShowsView())
            case .profile:
                return AnyView(ShowsView())
            }
        }
    }
    
    func button(for value: STTabBarButton) -> some View {
        Button {
            appState.selectedTabBarView = value
        } label: {
            Image(value.imageName)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(appState.selectedTabBarView == value ? Color.bay : Color.text100)
        }
    }
}

// MARK: - Helpers

private extension TabBarView {
    var spacing: CGFloat {
        (geometry.size.width - 2 * Constants.horizontalPadding - CGFloat(Constants.numberOfItems) * Constants.iconSize.width) / CGFloat((Constants.numberOfItems - 1))
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

// MARK: - Extensions

extension STTabBarButton {
    var imageName: String {
        switch self {
        case .shows: return "Icons/TabBar/tv"
        case .movies: return "Icons/TabBar/movies"
        case .profile: return "Icons/TabBar/profile"
        }
    }
}

// MARK: - Preview

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        Resolver.registerPreview()

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
