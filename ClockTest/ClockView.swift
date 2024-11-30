//
//  ClockView.swift
//  ClockTest
//
//  Created by Ben Davis on 9/20/24.
//

import SwiftUI
import CoreFoundation


extension CGRect {
    
    init(frame: CGRect, insetRatio: Double) {
        let insetWidth = frame.size.width * insetRatio
        let insetHeight = frame.size.height * insetRatio
        self.init()
        self.origin = CGPoint(x: frame.origin.x - (insetWidth / 2.0), y: frame.origin.y - (insetHeight / 2.0))
        self.size = CGSize(width: insetWidth, height: insetHeight)
        
    }

}

struct ClockView: View {
    
    struct ClockDesign {
        var background: GraphicsContext.Shading
        let border: GraphicsContext.Shading
        let labelColor: Color
        let minuteHandColor: GraphicsContext.Shading
        let secondHandColor: GraphicsContext.Shading
        let hourHandColor: GraphicsContext.Shading
        let useHandShadow: Bool
        let useLabelShadow: Bool
        
        init(background: GraphicsContext.Shading = GraphicsContext.Shading.color(Color("ClockBackground")),
             border: GraphicsContext.Shading = .color(Color("ClockBorder")),
             labelColor: Color = Color.black,
             hourHandColor: GraphicsContext.Shading = .color(Color.black),
             minuteHandColor: GraphicsContext.Shading = .color(Color.black),
             secondHandColor: GraphicsContext.Shading = .color(Color("SecondHand")),
             useHandShadow: Bool = true,
             useLabelShadow: Bool = true) {
            
            self.background = background
            self.border = border
            self.labelColor = labelColor
            self.minuteHandColor = minuteHandColor
            self.hourHandColor = hourHandColor
            self.secondHandColor = secondHandColor
            self.useHandShadow = useHandShadow
            self.useLabelShadow = true
        }
    }
    
    enum ClockHandStyle: String, CaseIterable {
        case hour, minute, second
    }
    
    private let labels: [String] = ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
    
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

                // Draws the static components of the clock: The border, clock background, and labels.
                drawClockBody(in: context, frame: clockFrame)
                
                // Draws the labels
                drawLabels(in: context, frame: clockFrame)
                
                // Draws the hatch marks
                drawHatchMarks(in: context, frame: clockFrame)

                
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
    
    /// Draw hatch marks on clock
    /// context: GraphicsContext the context in which to draw the hatch marks
    /// frame: CGRect the frame to use.
    ///
    private func drawHatchMarks(in context: GraphicsContext, frame: CGRect) {
        let center = CGPoint(x: frame.midX, y: frame.midY)
        let radius = min(frame.width, frame.height) / 2 * 0.95
        let hatchLength = radius * 0.05 // 10% of clock radius
        
        for index in 0 ..< 60 {
            let angle = CGFloat(index) * .pi * 2 / 60 - .pi / 2
            let startRadius = radius - hatchLength
            let endRadius = radius
            
            let isHourMark = (index % 5 == 0)
            
            let trueStartRadius = isHourMark ? startRadius - hatchLength : startRadius
            
            let startPoint = CGPoint(x: (center.x + cos(angle) * trueStartRadius),
                                     y: (center.y + sin(angle) * trueStartRadius))
            
            let endPoint = CGPoint(x: center.x + cos(angle) * endRadius,
                                   y: center.y + sin(angle) * endRadius)
            var path = Path()
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            
            context.stroke(path, with: .color(isHourMark ? .primary : .secondary), lineWidth: 1)
        }

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
    
    private func drawLabels(in context: GraphicsContext, frame: CGRect) {
        // translate inner context to ensure labels are offset correctly
        var inner = context
//        inner.translateBy(x: 0, y: 11)
        
        if self.design.useLabelShadow {
            inner.addFilter(.shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1))
        }
        // radius of inner circle that will define label origin:
        // 75% of outer frame
        let radius = min(frame.width, frame.height) / 2 * 0.70
        
        let fontSize = min(frame.width, frame.height) / 10

        
        // NOTE: Having trouble ensuring the "10" is offset from the hatch mark at the same distance as "2".
        // * Tried using the size of the NSAttributedString to offset (x,y) but this makes the problem worse.
        
        for index in 0 ..< self.labels.count {
            let angle = CGFloat(index) * .pi * 2 / 12 - (.pi / 2)
            
            // Calculate position
            let x = cos(angle) * radius + frame.midX
            let y = sin(angle) * radius + frame.midY
            
            // Approximate text size
//            let approximateTextHeight = fontSize
            var attributedString = AttributedString(stringLiteral: self.labels[index])
            attributedString.foregroundColor = self.design.labelColor
            attributedString.font = .system(size: fontSize)
            
            
            
            inner.draw(Text(attributedString), at: CGPoint(x: x, y: y))
            
        }

    }
  
    /// Draws the static elements of the clock (the clock background and labels)
    /// - inContext context: GraphicsContext the context in which to draw the clock
    /// - frame: CGRect the frame in which to draw the clock body.
    ///
    private func drawClockBody(in context: GraphicsContext, frame: CGRect) {
        // ellipse for the clock path
        let borderPath = Path(ellipseIn: frame)
              
        // fill clock design
        context.fill(borderPath, with: self.design.background)
        
        // stroke clock border
        context.stroke(borderPath, with: self.design.border, style: StrokeStyle(lineWidth: 2))
        
    }
}

#Preview {
    TimelineView(.periodic(from: .now, by: 1)) { tContext in
        ClockView(date: Date())
    }
}
