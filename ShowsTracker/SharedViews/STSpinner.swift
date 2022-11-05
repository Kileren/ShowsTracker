//
//  STSpinner.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 13.10.2022.
//

import SwiftUI

struct STSpinner: View {
    
    let rotationTime: Double = 0.75
    let fullRotation: Angle = .degrees(360)
    let animationTime: Double = 1.9
    static let initialDegree: Angle = .degrees(270)
    
    @State var spinnerStart: CGFloat = 0.0
    @State var spinnerEndS1: CGFloat = 0.03
    @State var rotationDegreeS1 = initialDegree
    
    @State var spinnerEndS2: CGFloat = 0.03
    @State var rotationDegreeS2 = initialDegree
    
    @State var spinnerEndS3: CGFloat = 0.03
    @State var rotationDegreeS3 = initialDegree
    
    var body: some View {
        ZStack {
            SpinnerCircle(
                start: spinnerStart,
                end: spinnerEndS2,
                rotation: rotationDegreeS3,
                color: .text100)
            
            SpinnerCircle(
                start: spinnerStart,
                end: spinnerEndS3,
                rotation: rotationDegreeS2,
                color: .redSoft)
            
            SpinnerCircle(
                start: spinnerStart,
                end: spinnerEndS1,
                rotation: rotationDegreeS1,
                color: .dynamic.bay)
        }
        .frame(width: 20, height: 20)
        .onAppear() {
            self.animateSpinner()
            Timer.scheduledTimer(withTimeInterval: animationTime, repeats: true) { _ in
                self.animateSpinner()
            }
        }
    }
    
    func animateSpinner(with timeInterval: Double, completion: @escaping (() -> Void)) {
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            withAnimation(Animation.easeInOut(duration: rotationTime)) {
                completion()
            }
        }
    }
    
    func animateSpinner() {
        animateSpinner(with: rotationTime) {
            self.spinnerEndS1 = 1.0
        }
        animateSpinner(with: (rotationTime * 2)) {
            self.spinnerEndS1 = 0.03
            self.spinnerEndS2 = 0.03
            self.spinnerEndS3 = 0.03
        }
        animateSpinner(with: (rotationTime * 2) - 0.03) {
            self.rotationDegreeS1 += fullRotation
            self.spinnerEndS2 = 0.8
            self.spinnerEndS3 = 0.8
        }
        animateSpinner(with: (rotationTime * 2) + 0.0525) {
            self.rotationDegreeS2 += fullRotation
        }
        animateSpinner(with: (rotationTime * 2) + 0.225) {
            self.rotationDegreeS3 += fullRotation
        }
    }
}

private struct SpinnerCircle: View {
    var start: CGFloat
    var end: CGFloat
    var rotation: Angle
    var color: Color
    
    var body: some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .fill(color)
            .rotationEffect(rotation)
    }
}

struct STSpinner_Previews: PreviewProvider {
    static var previews: some View {
        STSpinner()
    }
}
