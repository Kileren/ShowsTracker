//
//  UpdatesView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 29.04.2023.
//

import SwiftUI

struct UpdatesView: View {
    
    @StateObject private var viewModel = UpdatesViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            title
            switch viewModel.model.state {
            case .loading:
                UpdatesLoadingView()
            case .updated(let models):
                UpdatedShowsView(models: models)
            case .updatesNotFound(let lastCheck):
                spacer
                UpdatesNotFoundView(lastCheck: lastCheck)
                spacer
                spacer
            }
        }
        .background(Color.dynamic.background)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(Strings.close) { dismiss.callAsFunction() }
            }
        }
        .embedInNavigationView()
        .task {
            await viewModel.onAppear()
        }
    }
}

// MARK: - Views

private extension UpdatesView {
    var title: some View {
        HStack {
            Text(Strings.whatsNew)
                .font(.bold34)
                .foregroundColor(.dynamic.text100)
            spacer
        }
        .padding(.horizontal, 24)
    }
    
    var spacer: Spacer { Spacer() }
}

struct UpdatesView_Previews: PreviewProvider {
    static var previews: some View {
        UpdatesView()
    }
}
