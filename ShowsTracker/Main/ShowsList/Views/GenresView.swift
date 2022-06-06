//
//  GenresView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 28.05.2022.
//

import SwiftUI

struct GenresView: View {
    
    let tags: [Model.Tag]
    let onClose: () -> Void
    let onConfirm: (Set<Model.Tag>) -> Void
    
    @State private var viewOffset: CGFloat = 0
    @State private var selectedTags: Set<Model.Tag> = []
    
    init(tags: [Model.Tag],
         selectedTags: Set<Model.Tag>,
         onClose: @escaping () -> Void,
         onConfirm: @escaping (Set<Model.Tag>) -> Void) {
        self.tags = tags
        self.selectedTags = selectedTags
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
        .animation(.interactiveSpring(), value: selectedTags)
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
                    selectedTags = []
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
            ForEach(tagsByLines, id: \.self) { line in
                HStack(spacing: 24) {
                    ForEach(line, id: \.self) { tag in
                        Text(tag.text)
                            .font(.regular13)
                            .foregroundColor(isSelected(tag) ? .white100 : .text100)
                            .frame(height: 24)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .frame(height: 24)
                                    .foregroundColor(isSelected(tag) ? .bay : .separators)
                                    .padding(.horizontal, -8)
                            )
                            .onTapGesture {
                                if isSelected(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    var confirmButton: some View {
        Button {
            onConfirm(selectedTags)
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
    var tagsByLines: [[Model.Tag]] {
        let fontAttr: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 13)]
        let horizontalOffset: CGFloat = 16
        let cellInsets: CGFloat = 16
        let spacing: CGFloat = 8
        let allowedWidth = UIScreen.main.bounds.width - 2 * horizontalOffset
        
        var result: [[Model.Tag]] = []
        var currentLine: [Model.Tag] = []
        var currentFreeSpace = allowedWidth
        for tag in tags {
            let cellWidth = (tag.text as NSString).size(withAttributes: fontAttr).width + cellInsets
            if currentFreeSpace > cellWidth {
                currentLine.append(tag)
                currentFreeSpace -= cellWidth + spacing
            } else {
                result.append(currentLine)
                currentLine = [tag]
                currentFreeSpace = allowedWidth - cellWidth - spacing
            }
        }
        if !currentLine.isEmpty {
            result.append(currentLine)
        }
        return result
    }
    
    func isSelected(_ tag: Model.Tag) -> Bool {
        selectedTags.contains(tag)
    }
}

// MARK: - Model

extension GenresView {
    struct Model: Equatable, Hashable {
        var tags: [Tag] = []
        
        struct Tag: Equatable, Hashable {
            var id: Int = 0
            var text: String = ""
        }
    }
}

struct GenresView_Previews: PreviewProvider {
    
    @State static var selectedTags: Set<GenresView.Model.Tag> = []
    @State static var isPresented: Bool = true
    
    static var previews: some View {
        GenresView(
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
            selectedTags: [],
            onClose: { },
            onConfirm: { _ in }
        )
    }
}
