//
//  ClockDesign.swift
//  ClockTest
//
//  Created by Ben Davis on 12/3/24.
//

import Foundation
import SwiftUI

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
