//
//  ClockAnimatable.swift
//  ClockTest
//
//  Created by Ben Davis on 12/3/24.
//

import Foundation
import SwiftUI

/**
 ClockAnimatable is the animatable component. Contains hour, minute, and second hands.
 */
struct ClockAnimatable: View {
    
    enum ClockHandStyle: String, CaseIterable {
        case hour, minute, second
    }
        
    private let date: Date
    private let design: ClockDesign
    @State private var positions: [CGPoint] = []
    
    init(date: Date, design: ClockDesign = ClockDesign()) {
        self.date = date
        self.design = design
    }
    
    var body: some View {

            Canvas { (context, size) in
                let minSide = min(size.width, size.height)
                /// Inset the frame to ensure the clock can fit in the view size.
                let insetFrame = CGRect(frame: CGRect(origin: .zero,
                                                      size: CGSize(width: minSide, height: minSide)),
                                        insetRatio: 0.80)
                
                let clockFrame = CGRect(origin: CGPoint(x: (size.width / 2) - (insetFrame.size.width / 2), y: (size.height / 2) - (insetFrame.size.height / 2)), size: insetFrame.size)
                
                // Draws the hands for the clock.
                drawClockHands(in: context, frame: clockFrame, date: self.date)
            }
    }
    
    private func drawClockHands(in context: GraphicsContext, frame: CGRect, date: Date) {
        let hourPath = handPath(date: date, handStyle: .hour, frame: frame)
        var hourContext = context
        if self.design.useHandShadow {
            hourContext.addFilter(.shadow(color: .black, radius: 2, x: 1, y: 1))
        }
        context.stroke(hourPath, with: self.design.hourHandColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))

        let minutePath = handPath(date: date, handStyle: .minute, frame: frame)
        hourContext.stroke(minutePath, with: self.design.minuteHandColor, style: StrokeStyle(lineWidth: 1, lineCap: .round))
        
        let secondPath = handPath(date: date, handStyle: .second, frame: frame)
        hourContext.stroke(secondPath, with: self.design.secondHandColor, style: StrokeStyle(lineWidth: 0.50))
        
        // center point, "anchor" where the hands are pinned, as if this were a physical clock
        let centerPath = Path(ellipseIn: CGRect(origin: CGPoint(x: frame.midX - 2, y: frame.midY - 2),
                                                  size: CGSize(width: 4, height: 4)))
        context.fill(centerPath, with: .color(.black))
        
        let centerHole = Path(ellipseIn: CGRect(origin: CGPoint(x: frame.midX - 1, y: frame.midY - 1),
                                                size: CGSize(width: 2, height: 2)))
        context.fill(centerHole, with: .color(.white))

    }
    
    /// Sets Scale for clock hands.
    /// - fromDate: Date
    /// - type: ClockHandStyle the hand style for the clock (hour, minute, second)
    /// returns: Tuple of the Degree & Scale for the hand style
    ///
    private func getDegreeAndScale(fromDate: Date, type: ClockHandStyle) -> (CGFloat, CGFloat) {
        let calendar = Calendar.current
        var timeDegree = 0.0
        var widthScale = 1.0
        
        switch type {
        case .hour:
            // we have 12 hours so we need to multiply by 5 to have a scale of 60
            timeDegree = CGFloat(calendar.component(.hour, from: fromDate)) * 5
            widthScale = 0.4
        case .minute:
            timeDegree = CGFloat(calendar.component(.minute, from: fromDate))
            widthScale = 0.6
        case .second:
            timeDegree = CGFloat(calendar.component(.second, from: fromDate))
            widthScale = 0.8
        }
        return (timeDegree, widthScale)
    }
    
    /// Builds the path for the clock hands
    /// - date: Date
    /// - style: ClockHandStyle
    /// - frame: CGRect
    /// returns: Path of the hands for the clock.
    ///
    private func handPath(date: Date, handStyle style: ClockHandStyle, frame: CGRect) -> Path {
        var timeDegree = 0.0
        var widthScale = 1.0

        let midX = frame.midX
        let midY = frame.midY
        let radius = (frame.size.width / 2)
        let (degree, scale) = getDegreeAndScale(fromDate: date, type: style)
        timeDegree = degree
        widthScale = scale
        /// negate `timeDegree` - otherwise clock hands will move backwards
        timeDegree =  -timeDegree * .pi * 2 / 60 - (.pi)

        let startPoint = CGPoint(x: midX, y: midY)
       
        let endX = (widthScale * radius) * sin(timeDegree) + midX
        let endY = (widthScale * radius) * cos(timeDegree) + midY

        let endPoint = CGPoint(x: endX, y: endY)
        var path = Path()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        return path
    }
    
}

#Preview {
    ClockAnimatable(date: Date())
}
