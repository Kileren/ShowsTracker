//
//  GenresView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 28.05.2022.
//

import SwiftUI

struct GenresView: View {
    
    let genres: [Genre]
    let onClose: () -> Void
    let onConfirm: (Set<Genre>) -> Void
    
    @State private var viewOffset: CGFloat = 0
    @State private var selectedGenres: Set<Genre> = []
    
    init(genres: [Genre],
         selectedGenres: Set<Genre>,
         onClose: @escaping () -> Void,
         onConfirm: @escaping (Set<Genre>) -> Void) {
        self.genres = genres
        self.selectedGenres = selectedGenres
        self.onClose = onClose
        self.onConfirm = onConfirm
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                notchView
                titleView
            }
            tagsView
            confirmButton
            STSpacer(height: 0)
        }
        .padding(.horizontal, 16)
        .animation(.interactiveSpring(), value: selectedGenres)
        .background {
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(16, corners: [.topLeft, .topRight])
                .ignoresSafeArea(edges: .bottom)
                .padding(.bottom, min(viewOffset, 0))
        }
        .modifier(Dragging(offset: $viewOffset, onClose: onClose))
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
            Text("Жанры")
                .font(.semibold20)
                .foregroundColor(.text100)
            HStack {
                Spacer()
                Button {
                    selectedGenres = []
                } label: {
                    Text("Очистить")
                        .font(.regular13)
                        .foregroundColor(.text40)
                }
            }
        }
    }
    
    var tagsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(genresByLines, id: \.self) { line in
                HStack(spacing: 24) {
                    ForEach(line, id: \.self) { genre in
                        Text(genre.name ?? "")
                            .font(.regular13)
                            .foregroundColor(isSelected(genre) ? .white100 : .text100)
                            .frame(height: 24)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(height: 24)
                                    .foregroundColor(isSelected(genre) ? .bay : .separators)
                                    .padding(.horizontal, -8)
                            )
                            .onTapGesture {
                                if isSelected(genre) {
                                    selectedGenres.remove(genre)
                                } else {
                                    selectedGenres.insert(genre)
                                }
                            }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    var confirmButton: some View {
        Button {
            onConfirm(selectedGenres)
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

// MARK: - Helpers

private extension GenresView {
    var genresByLines: [[Genre]] {
        let fontAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13)]
        let horizontalOffset: CGFloat = 8
        let cellInsets: CGFloat = 16
        let spacing: CGFloat = 8
        let allowedWidth = UIScreen.main.bounds.width - 2 * horizontalOffset
        
        var result: [[Genre]] = []
        var currentLine: [Genre] = []
        var currentFreeSpace = allowedWidth
        for genre in genres {
            let cellWidth = ((genre.name ?? "") as NSString).size(withAttributes: fontAttr).width + cellInsets
            if currentFreeSpace > cellWidth {
                currentLine.append(genre)
                currentFreeSpace -= cellWidth + spacing
            } else {
                result.append(currentLine)
                currentLine = [genre]
                currentFreeSpace = allowedWidth - cellWidth - spacing
            }
        }
        if !currentLine.isEmpty {
            result.append(currentLine)
        }
        return result
    }
    
    func isSelected(_ genre: Genre) -> Bool {
        selectedGenres.contains(genre)
    }
}

struct GenresView_Previews: PreviewProvider {
    
    @State static var selectedTags: Set<Genre> = []
    @State static var isPresented: Bool = true
    
    static var previews: some View {
        GenresView(
            genres: [
                .init(id: 10759, name: "Action & Adventure"),
                .init(id: 16, name: "Animation"),
                .init(id: 35, name: "Comedy"),
                .init(id: 80, name: "Crime"),
                .init(id: 99, name: "Documentary"),
                .init(id: 18, name: "Drama"),
                .init(id: 10751, name: "Family"),
                .init(id: 10762, name: "Kids"),
                .init(id: 9648, name: "Mystery"),
                .init(id: 10763, name: "News"),
                .init(id: 10764, name: "Reality"),
                .init(id: 10765, name: "Sci-Fi & Fantasy"),
                .init(id: 10766, name: "Soap"),
                .init(id: 10767, name: "Talk"),
                .init(id: 10768, name: "War & Politics"),
                .init(id: 37, name: "Western")
            ],
            selectedGenres: [],
            onClose: { },
            onConfirm: { _ in }
        )
    }
}
