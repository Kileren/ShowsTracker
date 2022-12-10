//
//  NetworkErrorView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 09.12.2022.
//

import SwiftUI
import Resolver

struct NetworkErrorView: View {
    
    @Injected private var pingService: IPingService
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var animating: Bool = false
    
    var body: some View {
        ZStack {
            Color.dynamic.background.ignoresSafeArea()
            VStack(spacing: 44) {
                Spacer(minLength: 0)
                imageView
                VStack(alignment: .leading, spacing: 16) {
                    instructionView(with: Strings.networkErrorHint1)
                    instructionView(with: Strings.networkErrorHint2)
                }
                Spacer(minLength: 0)
                retryButton
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(Strings.networkError)
        .embedInNavigationView()
    }
    
    var imageView: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: "network")
                .resizable()
                .frame(width: 75, height: 75)
                .foregroundColor(.dynamic.text100)
            Circle()
                .frame(width: 32, height: 32)
                .foregroundColor(.redSoft)
                .overlay {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .frame(width: 18, height: 16)
                        .foregroundColor(.white100)
                        .padding(.bottom, 2)
                }
        }
    }
    
    func instructionView(with text: String) -> some View {
        HStack {
            Text(text)
                .font(.regular17)
                .foregroundColor(.dynamic.text100)
            Spacer(minLength: 0)
        }
        .padding(.all, 16)
        .frame(width: UIScreen.main.bounds.width - 48)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.dynamic.backgroundEl2)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 4, y: 4)
                .frame(width: UIScreen.main.bounds.width - 48)
        }
    }
    
    var retryButton: some View {
        STButton(title: Strings.tryAgain, style: .normal, animating: $animating) {
            Task {
                await setAnimating(true)
                let networkIsAvailable = await pingService.ping()
                if networkIsAvailable {
                    await dismissView()
                } else {
                    await setAnimating(false)
                }
            }
        }
    }
}

private extension NetworkErrorView {
    @MainActor
    func dismissView() {
        dismiss.callAsFunction()
    }
    
    @MainActor
    func setAnimating(_ value: Bool) {
        animating = value
    }
}

struct NetworkErrorView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkErrorView()
    }
}
