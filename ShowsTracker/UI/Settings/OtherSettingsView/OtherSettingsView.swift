//
//  OtherSettingsView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 26.11.2022.
//

import SwiftUI
import Resolver

struct OtherSettingsView: View {
    
    @Injected private var analyticsService: AnalyticsService
    
    @State private var trackEpisodesEnabled: Bool = AppSettings<EpisodesTrackingKey>
        .value(for: EpisodesTrackingKey.self)
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(Strings.episodesTracking)
                        .font(.medium17)
                        .foregroundColor(.dynamic.text100)
                    .padding([.leading, .top], 12)
                    
                    Text(Strings.episodesTrackingDescription)
                        .font(.regular11)
                        .foregroundColor(.dynamic.text40)
                        .padding([.leading, .bottom], 12)
                }
                Spacer()
                Toggle("", isOn: $trackEpisodesEnabled)
                    .labelsHidden()
                    .tint(.bay)
                    .padding([.top, .trailing], 12)
            }
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.dynamic.backgroundEl2)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 4, y: 4)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .navigationTitle(Strings.additionally)
        .onChange(of: trackEpisodesEnabled) { newValue in
            AppSettings<EpisodesTrackingKey>.setValue(
                value: newValue,
                for: EpisodesTrackingKey.self)
            analyticsService.setUserProperty(
                property: .episodesTrackingEnabled(value: newValue)
            )
        }
    }
}

struct OtherSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        OtherSettingsView()
    }
}
