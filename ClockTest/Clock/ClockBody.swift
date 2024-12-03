//
//  ClockBody.swift
//  ClockTest
//
//  Created by Ben Davis on 12/3/24.
//

import Foundation
import SwiftUI

/** ClockBody is the background (body) of the clock, comprising the background, hatch marks, and labels.
 */

struct ClockBody: View {
    let design: ClockDesign
    let labels: [String]
    
    init(design: ClockDesign = ClockDesign(), labels: [String] = ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]) {
        self.design = design
        self.labels = labels
    }

    var body: some View {
        Canvas { context, size in
            let minSide = min(size.width, size.height)
            /// Inset the frame to ensure the clock can fit in the view size.
            let insetFrame = CGRect(frame: CGRect(origin: .zero,
                                                  size: CGSize(width: minSide,
                                                               height: minSide)),
                                    insetRatio: 0.80)
            
            let clockFrame = CGRect(origin: CGPoint(x: (size.width / 2) - (insetFrame.size.width / 2),
                                                    y: (size.height / 2) - (insetFrame.size.height / 2)),
                                    size: insetFrame.size)

            drawClockBody(in: context,
                          frame: clockFrame)
            drawLabels(in: context,
                       frame: clockFrame)
            drawHatchMarks(in: context,
                           frame: clockFrame)
        }
    }

    private func drawLabels(in context: GraphicsContext,
                            frame: CGRect) {
        // Necessary to call `addFilter` - we need context to be mutable
        var inner = context
        
        if self.design.useLabelShadow {
            inner.addFilter(.shadow(color: .black.opacity(0.5),
                                    radius: 1,
                                    x: 0,
                                    y: 1))
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

            inner.draw(Text(attributedString),
                       at: CGPoint(x: x,
                                   y: y))
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
        context.fill(borderPath,
                     with: self.design.background)
        
        // stroke clock border
        context.stroke(borderPath,
                       with: self.design.border,
                       style: StrokeStyle(lineWidth: 2))
        
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
            
            context.stroke(path,
                           with: .color(isHourMark ? .primary : .secondary),
                           lineWidth: 1)
        }

    }


}
#Preview {
    ClockBody()
}
