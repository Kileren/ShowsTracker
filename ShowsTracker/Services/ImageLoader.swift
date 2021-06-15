//
//  ImageLoader.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 14.06.2021.
//

import UIKit
import SwiftUI

final class ImageLoader {
    
    func obtainImage(ofType type: ImageProvidableType, from imageProvidable: ImageProvidable) async -> UIImage {
        imageProvidable.posterPath == "/zrPpUlehQaBf8YX2NrVrKK8IEpf.jpg"
            ? UIImage(named: "TheWitcher") ?? UIImage()
            : UIImage(named: "TheMandalorian") ?? UIImage()
    }
    
    func obtainImage(byShortPath path: String) async -> UIImage {
        path == "/zrPpUlehQaBf8YX2NrVrKK8IEpf.jpg"
            ? UIImage(named: "TheWitcher") ?? UIImage()
            : UIImage(named: "TheMandalorian") ?? UIImage()
    }
    
    func obtainImage(byFullPath path: String) async -> UIImage {
        path == "https://image.tmdb.org/t/p/w500/zrPpUlehQaBf8YX2NrVrKK8IEpf.jpg"
            ? UIImage(named: "TheWitcher") ?? UIImage()
            : UIImage(named: "TheMandalorian") ?? UIImage()
    }
}
