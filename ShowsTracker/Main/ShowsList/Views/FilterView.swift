//
//  FilterView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 22.05.2022.
//

import Combine
import SwiftUI
import Resolver

struct FilterView: View {
    
    @State private var lowerYear: Int
    @State private var upperYear: Int
    
    @State private var genresViewIsActive: Bool = false
    @State private var genresViewIsShown: Bool = false
    
    @State private var languageViewIsActive: Bool = false
    @State private var languageViewIsShown: Bool = false
    
    @State private var viewOffset: CGFloat = 0
    
    @State private var model: Model
    
    let onConfirm: (Model) -> Void
    let onClose: () -> Void
    
    init(model: Model, onConfirm: @escaping (Model) -> Void, onClose: @escaping () -> Void) {
        self.model = model
        self.lowerYear = model.minYear
        self.upperYear = model.maxYear
        self.onConfirm = onConfirm
        self.onClose = onClose
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 16) {
                    notchView
                    titleView
                }
                yearView
                genresSelectorView
                languageSelectorView
                sortView
                confirmButton.modifier(HorizontalAlignment())
                STSpacer(height: 8)
            }
            .padding(.horizontal, 16)
            .background {
                Rectangle()
                    .foregroundColor(.backgroundLight)
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .ignoresSafeArea(edges: .bottom)
                    .padding(.bottom, min(viewOffset, 0))
            }
            .modifier(Dragging(offset: $viewOffset, onClose: onClose))
            
            if genresViewIsActive {
                genresView
            }
            if languageViewIsActive {
                languageView
            }
        }
        .onChange(of: lowerYear) { model.minYear = $0 }
        .onChange(of: upperYear) { model.maxYear = $0 }
    }
    
    var notchView: some View {
        VStack(spacing: 0) {
            STSpacer(height: 8, width: nil, color: .white100)
            RoundedRectangle(cornerRadius: 2.5)
                .frame(width: 50, height: 5)
                .foregroundColor(.graySimple)
        }
    }
    
    var titleView: some View {
        ZStack {
            Text("Фильтры")
                .font(.semibold20)
                .foregroundColor(.text100)
            HStack {
                Spacer()
                Text("Очистить")
                    .font(.regular13)
                    .foregroundColor(.text40)
            }
        }
    }
    
    var yearView: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Год выпуска")
                    .font(.medium17)
                    .foregroundColor(.text100)
                Spacer()
                Text("\(model.minYear.description) - \(model.maxYear.description)")
                    .font(.medium13)
                    .foregroundColor(.text60)
            }
            SliderView(
                minValue: Model.originalMinYear,
                maxValue: Model.originalMaxYear,
                lowerValue: $lowerYear,
                upperValue: $upperYear)
        }
    }
    
    var genresSelectorView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Жанры")
                .font(.medium17)
                .foregroundColor(.text100)
            
            Button {
                genresViewIsActive = true
            } label: {
                ZStack {
                    if model.selectedGenres.isEmpty {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.bay, lineWidth: 1)
                            .frame(width: 130, height: 32)
                        Text("Все")
                            .font(.regular15)
                            .foregroundColor(.bay)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .foregroundColor(.bay)
                            .frame(width: 130, height: 32)
                        Text(Strings.genrePlural(model.selectedGenres.count))
                            .font(.regular15)
                            .foregroundColor(.white100)
                    }
                }
            }
        }
    }
    
    var languageSelectorView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Язык оригинала")
                .font(.medium17)
                .foregroundColor(.text100)
            
            Button {
                languageViewIsActive = true
            } label: {
                ZStack {
                    if let originalLanguage = model.selectedOriginalLanguage {
                        Text(originalLanguage.nameRu)
                            .font(.regular15)
                            .foregroundColor(.white100)
                            .frame(height: 32)
                            .frame(minWidth: 98)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .foregroundColor(.bay)
                                    .frame(height: 32)
                                    .frame(minWidth: 98)
                                    .padding(.horizontal, -16)
                            }
                            .padding(.horizontal, 16)
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.bay, lineWidth: 1)
                            .frame(width: 130, height: 32)
                        Text("Любой")
                            .font(.regular15)
                            .foregroundColor(.bay)
                    }
                }
            }
        }
    }
    
    var genresView: some View {
        ZStack {
            Rectangle()
                .foregroundColor(genresViewIsShown ? .black.opacity(0.25) : .black.opacity(0))
                .animation(.easeInOut, value: genresViewIsShown)
                .ignoresSafeArea()
                .padding(.top, -44)
                .disableDragging()
                .onTapGesture {
                    genresViewIsShown = false
                    after(timeout: 0.3) { genresViewIsActive = false }
                }
            VStack(spacing: 0) {
                Spacer()
                GenresView(
                    genres: model.allGenres,
                    selectedGenres: model.selectedGenres) {
                        genresViewIsShown = false
                        after(timeout: 0.3) { genresViewIsActive = false }
                    } onConfirm: { selectedGenres in
                        model.selectedGenres = selectedGenres
                        genresViewIsShown = false
                        after(timeout: 0.3) { genresViewIsActive = false }
                    }
                    .offset(y: genresViewIsShown ? 0 : 500)
                    .animation(.easeInOut, value: genresViewIsShown)
            }
        }
        .onAppear {
            genresViewIsShown = true
        }
    }
    
    var languageView: some View {
        ZStack {
            Rectangle()
                .foregroundColor(languageViewIsShown ? .black.opacity(0.25) : .black.opacity(0))
                .animation(.easeInOut, value: languageViewIsShown)
                .ignoresSafeArea()
                .padding(.top, -44)
                .disableDragging()
                .onTapGesture {
                    languageViewIsShown = false
                    after(timeout: 0.3) { languageViewIsActive = false }
                }
            VStack(spacing: 0) {
                Spacer()
                LanguageSelectorView(selectedLanguage: model.selectedOriginalLanguage) { language in
                    model.selectedOriginalLanguage = language
                    languageViewIsShown = false
                    after(timeout: 0.3) { languageViewIsActive = false }
                }
                .offset(y: languageViewIsShown ? 0 : 500)
                .animation(.easeInOut, value: languageViewIsShown)
            }
        }
        .onAppear {
            languageViewIsShown = true
        }
    }
    
    var sortView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Сортировать по")
                .font(.medium17)
                .foregroundColor(.text100)
            sortingCell(for: .popularity)
            sortingCell(for: .airDate)
            sortingCell(for: .votes)
        }
    }
    
    func sortingCell(for sorting: Model.Sorting) -> some View {
        let isSelected = model.sorting == sorting
        return HStack(spacing: 8) {
            Circle()
                .strokeBorder(isSelected ? Color.bay : Color.graySimple, lineWidth: 1)
                .frame(width: 16, height: 16)
                .overlay {
                    if isSelected {
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundColor(.bay)
                    }
                }
            Text(sorting.name)
                .font(.regular13)
                .foregroundColor(.text100)
        }
        .onTapGesture {
            model.sorting = sorting
        }
    }
    
    var confirmButton: some View {
        Button {
            onConfirm(model)
        } label: {
            RoundedRectangle(cornerRadius: 16)
                .frame(width: 300, height: 50)
                .foregroundColor(.bay)
                .overlay {
                    Text("Подтвердить")
                        .font(.medium20)
                        .foregroundColor(.white100)
                }
        }
    }
}

// MARK: - Model

extension FilterView {
    struct Model: Equatable {
        var minYear = originalMinYear
        var maxYear = originalMaxYear
        var allGenres: [Genre] = []
        var selectedGenres: Set<Genre> = []
        var selectedOriginalLanguage: LangCode? = nil
        var sorting: Sorting = .popularity
        
        enum Sorting: Equatable {
            case popularity
            case airDate
            case votes
            
            var name: String {
                switch self {
                case .popularity: return "Популярности"
                case .airDate: return "Новизне"
                case .votes: return "Оценке"
                }
            }
        }
        
        var isEmpty: Bool {
            minYear == Self.originalMinYear &&
            maxYear == Self.originalMaxYear &&
            selectedGenres == [] &&
            selectedOriginalLanguage == nil &&
            sorting == .popularity
        }
        
        static let empty = Model()
        static var originalMinYear = 1950
        static var originalMaxYear = (Calendar.current.dateComponents([.year], from: .now).year ?? 2025) + 3
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(model: .empty) { _ in
            // Confirm button tapped
        } onClose: {
            // View closed
        }
    }
}
