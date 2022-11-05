//
//  LanguageSelectorView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 29.05.2022.
//

import SwiftUI

struct LanguageSelectorView: View {
    
    @State private var viewOffset: CGFloat = 0
    @State var selectedLanguage: LangCode? = nil
    
    let onClose: (LangCode?) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                notchView
                titleView
            }
            languagesView
            confirmButton
            STSpacer(height: 0)
        }
        .padding(.horizontal, 16)
        .background {
            Rectangle()
                .foregroundColor(.dynamic.backgroundEl1)
                .cornerRadius(16, corners: [.topLeft, .topRight])
                .ignoresSafeArea(edges: .bottom)
                .padding(.bottom, min(viewOffset, 0))
        }
        .modifier(Dragging(offset: $viewOffset, onClose: { onClose(selectedLanguage) }))
    }
    
    var notchView: some View {
        VStack(spacing: 0) {
            STSpacer(height: 8, width: nil)
            RoundedRectangle(cornerRadius: 2.5)
                .frame(width: 50, height: 5)
                .foregroundColor(Color(light: .graySimple, dark: .backgroundDarkEl2))
        }
    }
    
    var titleView: some View {
        ZStack {
            Text(Strings.originalLanguage)
                .font(.semibold20)
                .foregroundColor(.dynamic.text100)
            HStack {
                Spacer()
                Button {
                    selectedLanguage = nil
                } label: {
                    Text(Strings.clear)
                        .font(.regular13)
                        .foregroundColor(.dynamic.text40)
                }
            }
        }
    }
    
    var languagesView: some View {
        List(LangCode.allCases, id: \.self) { language in
            HStack {
                Text(language.nameRu)
                    .font(.medium17)
                    .foregroundColor(.dynamic.text100)
                    .frame(height: 40)
                Spacer()
                if selectedLanguage == language {
                    Image("checkmark")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
            }
            .listRowBackground(Color.backgroundDarkEl1)
            .frame(height: 40)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedLanguage = language
            }
        }
        .frame(height: 200)
        .listStyle(.plain)
        .padding(.leading, -20)
    }
    
    var confirmButton: some View {
        STButton(
            title: Strings.confirm,
            style: .custom(width: 300, height: 50, font: .medium20)) {
                onClose(selectedLanguage)
            }
    }
}

struct LanguageSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSelectorView(selectedLanguage: nil, onClose: { _ in })
    }
}
