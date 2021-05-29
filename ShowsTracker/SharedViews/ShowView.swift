//
//  ShowView.swift
//  ShowsTracker
//
//  Created by s.bogachev on 06.02.2021.
//

import SwiftUI

struct ShowView: View {
    
    var image: Image
    var title: String
    var rating: Double?
    
    @State private var isTextTruncated: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .trailing, spacing: 4) {
                imageView(geometry: geometry)
                titleView(geometry: geometry)
            }
        }
    }
    
    private func imageView(geometry: GeometryProxy) -> some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(DesignConst.smallCornerRadius)
                .frame(width: geometry.size.width,
                       height: geometry.size.width * 1.5)
            
            if let rating = self.rating {
                ratingView(rating: rating)
            }
        }
    }
    
    private func ratingView(rating: Double) -> some View {
        Rectangle()
            .cornerRadius(8, corners: [.topLeft, .bottomRight])
            .frame(width: 42, height: 18)
            .foregroundColor(.text100)
            .overlay(
                HStack(spacing: 4) {
                    Images.star
                        .resizable()
                        .frame(width: 10, height: 10)
                    
                    Text(rating.description)
                        .foregroundColor(.white100)
                        .font(.medium12)
                    
                    Spacer(minLength: 0)
                }
                .padding(.leading, 4)
            )
    }
    
    private func titleView(geometry: GeometryProxy) -> some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            TruncableText(text: Text(title), lineLimit: 2) {
                isTextTruncated = $0
            }
            .frame(width: geometry.size.width - 2,
                   alignment: .topLeading)
            .foregroundColor(.text100)
            .font(.medium12)
            
            if isTextTruncated {
                Rectangle()
                    .frame(width: geometry.size.width  - 2,
                           height: 12,
                           alignment: .center)
                    .foregroundColor(.clear)
                    .background(LinearGradient(gradient: Gradient(colors: [.white60, .white]), startPoint: .leading, endPoint: .trailing))
            }
        }
    }
}

struct ShowView_Previews: PreviewProvider {
    static var previews: some View {
        ShowView(image: Image("TheWitcher"),
                 title: "Леденящие душу приключения",
                 rating: 7.8)
            .frame(width: 100, height: 100 * 1.85)
    }
}
