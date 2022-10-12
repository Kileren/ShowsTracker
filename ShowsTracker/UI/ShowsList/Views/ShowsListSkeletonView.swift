//
//  ShowsListSkeletonView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 09.05.2022.
//

import SwiftUI

struct ShowsListSkeletonView: View {
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 108, height: 32)
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 68, height: 32)
            }
            
            VStack(spacing: 32) {
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 16)
                        .frame(height: 48)
                    RoundedRectangle(cornerRadius: 8)
                        .frame(width: 32, height: 32)
                }
                
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 14) {
                            showSkeleton(geometry: geometry)
                            showSkeleton(geometry: geometry)
                            showSkeleton(geometry: geometry)
                        }
                        HStack(spacing: 14) {
                            showSkeleton(geometry: geometry)
                            showSkeleton(geometry: geometry)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .foregroundColor(.separators)
    }
    
    func showSkeleton(geometry: GeometryProxy) -> some View {
        let spacing: CGFloat = 14
        let width = (geometry.size.width - 2 * spacing) / 3
        return VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: width, height: 158)
            RoundedRectangle(cornerRadius: 7)
                .frame(width: 72, height: 14)
            Spacer()
        }
        .frame(width: width, height: 190)
    }
}

struct ShowsListSkeletonView_Previews: PreviewProvider {
    static var previews: some View {
        ShowsListSkeletonView()
    }
}
