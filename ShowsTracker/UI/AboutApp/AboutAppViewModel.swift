//
//  AboutAppViewModel.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 25.11.2022.
//

import Foundation
import UIKit

final class AboutAppViewModel: ObservableObject {
    
    func didTapRateButton() {
        let appID = "6444506699"
        let urlStr = "https://itunes.apple.com/app/id\(appID)?action=write-review"
        
        if let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
        }
    }
}
