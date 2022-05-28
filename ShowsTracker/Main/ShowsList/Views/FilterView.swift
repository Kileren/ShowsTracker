//
//  FilterView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 22.05.2022.
//

import SwiftUI

struct FilterView: View {
    
    @State private var lowerYear = 1960
    @State private var upperYear = 2022
    
    private var minYear = 1960
    private var maxYear = 2022
    
    @State private var genresViewIsPresented: Bool = false
    @State private var genresViewIsShown: Bool = false
    
    @State private var selectedTags: Set<GenresView.Model.Tag> = []
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 24) {
                VStack(spacing: 16) {
                    notchView
                    titleView
                }
                yearView(geometry: geometry)
                genresView
            }
            .padding(.horizontal, 16)
        }
        .overlay {
            if genresViewIsPresented {
                ZStack {
                    Rectangle()
                        .foregroundColor(genresViewIsShown ? .black.opacity(0.25) : .black.opacity(0))
                        .animation(.easeInOut, value: genresViewIsShown)
                        .ignoresSafeArea()
                        .onTapGesture {
                            genresViewIsShown = false
                            after(timeout: 0.3) { genresViewIsPresented = false }
                        }
                    VStack(spacing: 0) {
                        Spacer()
                        GenresView(
                            selectedTags: $selectedTags,
                            tags: [
                                .init(id: 0, text: "Боевик и Приключения"),
                                .init(id: 0, text: "Вестерн"),
                                .init(id: 0, text: "Война и политика"),
                                .init(id: 0, text: "Детектив"),
                                .init(id: 0, text: "Детский"),
                                .init(id: 0, text: "Документальный"),
                                .init(id: 0, text: "Драма"),
                                .init(id: 0, text: "Комедия")
                            ],
                            onClose: {
                                genresViewIsShown = false
                                after(timeout: 0.3) { genresViewIsPresented = false }
                            })
                            .offset(y: genresViewIsShown ? 0 : 500)
                            .animation(.easeInOut, value: genresViewIsShown)
                    }
                }
                .onAppear {
                    genresViewIsShown = true
                }
            }
        }
    }
    
    var notchView: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .frame(width: 50, height: 5)
            .foregroundColor(.graySimple)
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
    
    func yearView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text("Год выпуска")
                    .font(.medium17)
                    .foregroundColor(.text100)
                Spacer()
                Text("\(lowerYear.description) - \(upperYear.description)")
                    .font(.medium13)
                    .foregroundColor(.text60)
            }
            SliderView(
                minValue: minYear,
                maxValue: maxYear,
                lowerValue: $lowerYear,
                upperValue: $upperYear,
                contentWidth: geometry.size.width)
        }
    }
    
    var genresView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Жанры")
                .font(.medium17)
                .foregroundColor(.text100)
            
            Button {
                genresViewIsPresented = true
            } label: {
                ZStack {
                    if selectedTags.isEmpty {
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
                        Text(Strings.genrePlural(selectedTags.count))
                            .font(.regular15)
                            .foregroundColor(.white100)
                    }
                }
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
