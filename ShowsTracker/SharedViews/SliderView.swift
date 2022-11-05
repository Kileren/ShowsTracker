//
//  SliderView.swift
//  ShowsTracker
//
//  Created by Sergey Bogachev on 26.05.2022.
//

import SwiftUI

struct SliderView: View {
    
    private static let leftStickStartXLocation: CGFloat = .horizontalPadding
    private static let rightStickStartXLocation: CGFloat = UIScreen.main.bounds.width - 14 - .circleSide
    private static let fullWidth = Self.rightStickStartXLocation - Self.leftStickStartXLocation - .circleSide
    
    @State private var leftStickLocation = CGPoint(x: leftStickStartXLocation, y: .circleSide / 2)
    @State private var rightStickLocation = CGPoint(x: rightStickStartXLocation, y: .circleSide / 2)
    @GestureState private var leftStickStartLocation: CGPoint? = nil
    @GestureState private var rightStickStartLocation: CGPoint? = nil
    
    @Binding private var lowerValue: Int
    @Binding private var upperValue: Int
    @State private var lowerValueIsVisible = false
    @State private var upperValueIsVisible = false
    
    private var minValue: Int
    private var maxValue: Int
    
    init(minValue: Int,
         maxValue: Int,
         lowerValue: Binding<Int>,
         upperValue: Binding<Int>) {
        self.minValue = minValue
        self.maxValue = maxValue
        self._lowerValue = lowerValue
        self._upperValue = upperValue
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
                .frame(height: 6)
                .foregroundColor(Color(light: .graySimple, dark: .backgroundDarkEl2))
            RoundedRectangle(cornerRadius: 3)
                .frame(width: rightStickLocation.x - leftStickLocation.x, height: 6)
                .foregroundColor(.dynamic.bay)
                .position(x: leftStickLocation.x / 2 + rightStickLocation.x / 2, y: .circleSide / 2)
            
            HStack {
                Text(minValue.description)
                    .font(.regular12)
                    .foregroundColor(.dynamic.text40)
                    .opacity(lowerValueIsVisible ? 1 : 0)
                    .animation(Animation.spring(), value: lowerValueIsVisible)
                Spacer()
                Text(maxValue.description)
                    .font(.regular12)
                    .foregroundColor(.dynamic.text40)
                    .opacity(upperValueIsVisible ? 1 : 0)
                    .animation(Animation.spring(), value: upperValueIsVisible)
            }
            .offset(y: 16)
            
            leftStickView
            rightStickView
        }
        .frame(height: 36)
        .onChange(of: leftStickLocation) { newValue in onLeftStickLocationChanged(newValue) }
        .onChange(of: rightStickLocation) { newValue in onRightStickLocationChanged(newValue) }
        .onAppear {
            let leftStickStartOffset = CGFloat(lowerValue - minValue) / CGFloat(maxValue - minValue) * Self.fullWidth
            let rightStickStartOffset = CGFloat(maxValue - upperValue) / CGFloat(maxValue - minValue) * Self.fullWidth
            leftStickLocation.x = leftStickStartOffset + Self.leftStickStartXLocation
            rightStickLocation.x = Self.rightStickStartXLocation - rightStickStartOffset
        }
    }
    
    var leftStickView: some View {
        stickView
            .position(CGPoint(x: leftStickLocation.x, y: .circleSide / 2))
            .gesture(leftStickDrag)
    }
    
    var rightStickView: some View {
        stickView
            .position(CGPoint(x: rightStickLocation.x, y: .circleSide / 2))
            .gesture(rightStickDrag)
    }
    
    var stickView: some View {
        ZStack {
            Circle()
                .frame(width: .circleSide, height: .circleSide)
                .foregroundColor(.dynamic.backgroundEl2)
            Circle()
                .frame(width: .circleSide - 2, height: .circleSide - 2)
                .foregroundColor(.dynamic.bay)
            
            HStack(spacing: 4) {
                Image(systemName: "arrowtriangle.forward.fill")
                    .resizable()
                    .frame(width: 6, height: 6)
                    .rotationEffect(.degrees(180))
                    .foregroundColor(.white100)
                Image(systemName: "arrowtriangle.forward.fill")
                    .resizable()
                    .frame(width: 6, height: 6)
                    .foregroundColor(.white100)
            }
        }
    }
}

// MARK: - Gestures & Locations

private extension SliderView {
    var leftStickDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = leftStickStartLocation ?? leftStickLocation
                newLocation.x += value.translation.width
                newLocation.x = min(
                    max(.horizontalPadding, newLocation.x),
                    rightStickLocation.x - .circleSide
                )
                newLocation.y += value.translation.height
                self.leftStickLocation = newLocation
            }
            .updating($leftStickStartLocation) { value, startLocation, transaction in
                startLocation = startLocation ?? leftStickLocation
            }
    }
    
    var rightStickDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = rightStickStartLocation ?? rightStickLocation
                newLocation.x += value.translation.width
                newLocation.x = min(
                    max(leftStickLocation.x + .circleSide, newLocation.x),
                    UIScreen.main.bounds.width - 32 - .circleSide / 2
                )
                self.rightStickLocation = newLocation
            }
            .updating($rightStickStartLocation) { value, startLocation, transaction in
                startLocation = startLocation ?? rightStickLocation
            }
    }
    
    func onLeftStickLocationChanged(_ newValue: CGPoint) {
        let translatedNewValue = newValue.x - Self.leftStickStartXLocation
        let numberOfValues = maxValue - minValue + 1
        let progress = translatedNewValue / Self.fullWidth
        if progress == 0 {
            lowerValue = minValue
        } else if progress == 1 {
            lowerValue = maxValue
        } else {
            lowerValue = minValue + Int(CGFloat(numberOfValues) * progress)
        }
        lowerValueIsVisible = translatedNewValue > .lowerUpperValueVisibleOffset
    }
    
    func onRightStickLocationChanged(_ newValue: CGPoint) {
        let translatedNewValue = Self.rightStickStartXLocation - newValue.x
        let numberOfValues = maxValue - minValue + 1
        let progress = translatedNewValue / Self.fullWidth
        if progress == 0 {
            upperValue = maxValue
        } else if progress == 1 {
            upperValue = minValue
        } else {
            upperValue = maxValue - Int(CGFloat(numberOfValues) * progress)
        }
        upperValueIsVisible = translatedNewValue > .lowerUpperValueVisibleOffset
    }
}

private extension CGFloat {
    static let circleSide: CGFloat = 36
    static let horizontalPadding: CGFloat = 16
    static let lowerUpperValueVisibleOffset: CGFloat = 24
}
