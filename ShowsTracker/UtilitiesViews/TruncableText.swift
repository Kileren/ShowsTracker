//
//  TruncableText.swift
//  ShowsTracker
//
//  Created by s.bogachev on 07.02.2021.
//

import SwiftUI

struct TruncableText: View {
    let text: Text
    let lineLimit: Int?
    let isTruncatedUpdate: (_ isTruncated: Bool) -> Void
    
    @State private var intrinsicSize: CGSize = .zero
    @State private var truncatedSize: CGSize = .zero
    
    var body: some View {
        text.lineLimit(lineLimit)
            .readSize { size in
                truncatedSize = size
                isTruncatedUpdate(truncatedSize != intrinsicSize)
            }
            .background(
                text.fixedSize(horizontal: false, vertical: true)
                    .hidden()
                    .readSize { size in
                        intrinsicSize = size
                        isTruncatedUpdate(truncatedSize != intrinsicSize)
                    }
            )
    }
}

struct TruncableText_Previews: PreviewProvider {
    static var previews: some View {
        let text = Text("Some message, some message, some message, some message")
        return TruncableText(
            text: text,
            lineLimit: 2,
            isTruncatedUpdate: { _ in })
            .frame(width: 100)
    }
}
