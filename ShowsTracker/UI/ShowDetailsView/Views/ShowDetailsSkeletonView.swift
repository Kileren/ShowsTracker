//
//  ShowDetailsSkeletonView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 03.05.2022.
//

import SwiftUI

struct ShowDetailsSkeletonView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                blurBackground(geometry: geometry)
                overlayView(geometry: geometry)
                
                VStack(alignment: .center, spacing: 0) {
                    imageViewPlaceholder(geometry: geometry)
                    spacer(height: 12)
                    titlePlaceholder(geometry: geometry)
                    spacer(height: 4)
                    broadcastYearsPlaceholder
                    spacer(height: 16)
                    mainInfoPlaceholder(geometry: geometry)
                    spacer(height: 24)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            infoTabsPlaceholder(geometry: geometry)
                            firstLineOfTabPlaceholder
                        }
                        Spacer()
                    }
                    .padding(.leading, 24)
                }
            }
        }
    }
    
    func overlayView(geometry: GeometryProxy) -> some View {
        Rectangle()
            .cornerRadius(DesignConst.normalCornerRadius,
                          corners: [.topLeft, .topRight])
            .foregroundColor(.white100)
            .ignoresSafeArea(edges: .bottom)
            .padding(.top, geometry.size.width * 0.42 + 8)
    }
    
    func blurBackground(geometry: GeometryProxy) -> some View {
        LinearGradient(gradient: .darkBackground, startPoint: .leading, endPoint: .trailing)
            .edgesIgnoringSafeArea(.all)
    }
    
    func imageViewPlaceholder(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: DesignConst.normalCornerRadius)
            .frame(width: geometry.size.width * 0.3,
                   height: geometry.size.width * 0.45)
            .foregroundColor(.separators)
            .padding(.top, 40)
    }
    
    func titlePlaceholder(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: DesignConst.normalCornerRadius)
            .frame(width: geometry.size.width * 0.65, height: 32)
            .foregroundColor(.separators)
    }
    
    var broadcastYearsPlaceholder: some View {
        RoundedRectangle(cornerRadius: 11)
            .frame(width: 70, height: 22)
            .foregroundColor(.separators)
    }
    
    func mainInfoPlaceholder(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: DesignConst.smallCornerRadius)
            .frame(width: geometry.size.width - 72, height: 34)
            .foregroundColor(.separators)
    }
    
    func infoTabsPlaceholder(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: DesignConst.smallCornerRadius)
            .frame(width: min(280, geometry.size.width - 72), height: 30)
            .foregroundColor(.separators)
    }
    
    var firstLineOfTabPlaceholder: some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 90, height: 20)
            .foregroundColor(.separators)
    }
    
    func spacer(height: CGFloat) -> some View {
        Rectangle()
            .frame(height: height)
            .foregroundColor(.clear)
    }
}

struct ShowDetailsSkeletonView_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsSkeletonView()
    }
}
