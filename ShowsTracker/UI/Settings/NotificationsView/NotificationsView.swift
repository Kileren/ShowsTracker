//
//  NotificationsView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 23.10.2022.
//

import SwiftUI
import Resolver

struct NotificationsView: View {
    
    @InjectedObject private var viewModel: NotificationsViewModel
    
    var body: some View {
        Group {
            switch viewModel.model.state {
            case .allowed:
                allowedView()
            case .denied:
                deniedView()
            case .notDetermined:
                notDeterminedView()
            case .loading:
                EmptyView()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .background {
            Color.backgroundLight.ignoresSafeArea()
        }
        .navigationTitle(Strings.notificationsTitle)
        .onChange(of: viewModel.model.selectedTime) { newValue in
            viewModel.notificationTimeDidChange(newValue)
        }
        .onAppear {
            viewModel.viewAppeared()
        }
    }
}

private extension NotificationsView {
    
    func allowedView() -> some View {
        VStack(spacing: 12) {
            viewWithInfo(
                image: Image(systemName: "clock.badge"),
                title: Strings.notificationsTimeTitle,
                description: Strings.notificationsTimeDescription) {
                    DatePicker("", selection: $viewModel.model.selectedTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .cornerRadius(12)
                }
            bottomTextView
            Spacer()
        }
    }
    
    func deniedView() -> some View {
        VStack(spacing: 16) {
            STSpacer(height: 16)
            bottomTextView
            STButton(title: Strings.goToSettings, style: .medium) {
                viewModel.didTapGoToSettings()
            }
            Spacer()
        }
    }
    
    func notDeterminedView() -> some View {
        VStack(spacing: 12) {
            viewWithInfo(
                image: Image(systemName: "bell.badge"),
                title: Strings.notificationsTitle,
                description: Strings.notificationsExplanationDescription) {
                    STButton(title: Strings.allow, style: .small(width: .fixed(90))) {
                        viewModel.didTapAllowNotification()
                    }
                }
            bottomTextView
            Spacer()
        }
    }
    
    func viewWithInfo(
        image: Image,
        title: String,
        description: String,
        @ViewBuilder rightContent: () -> some View
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 4, y: 4)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        image
                            .resizable()
                            .foregroundColor(.bay)
                            .frame(width: 25, height: 25)
                        Text(title)
                            .font(.medium17)
                            .foregroundColor(.text100)
                            .frame(height: 28)
                    }
                    Text(description)
                        .font(.regular11)
                        .foregroundColor(.text40)
                }
                Spacer(minLength: 24)
                VStack {
                    rightContent()
                    Spacer()
                }
            }
            .padding(.all, 12)
        }
        .frame(height: 94)
    }
    
    var bottomTextView: some View {
        var title: String {
            switch viewModel.model.state {
            case .allowed: return Strings.notificationsAllowedText
            case .denied: return Strings.notificationsDeniedText
            case .notDetermined: return Strings.notificationsNotDeterminedText
            case .loading: return ""
            }
        }
        return Text(title)
            .font(.regular11)
            .foregroundColor(.text40)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
