//
//  PagingTabView.swift
//  ShowsTracker
//
//  Created by s.bogachev on 31.01.2021.
//

import SwiftUI

struct PagingTabView: View {
    var body: some View {
        ScrollView {
//            LazyHStack {
//                PageView()
//            }
            
            LazyHStack(spacing: 32) {
                PageView()
            }
        }
    }
}

struct PagingTabView_Previews: PreviewProvider {
    static var previews: some View {
        PagingTabView()
    }
}

struct PageView: View {
    var body: some View {
        TabView {
            ForEach(0..<30) { i in
                ZStack {
                    Color.black
                    Text("Row: \(i)").foregroundColor(.white)
                }
                .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                .frame(width: 220, height: 340, alignment: .center)
            }
            .padding(.all, 10)
        }
        .frame(width: UIScreen.main.bounds.width, height: 340)
        .tabViewStyle(PageTabViewStyle())
    }
}
