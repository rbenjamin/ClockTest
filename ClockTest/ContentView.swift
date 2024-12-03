//
//  ContentView.swift
//  ClockTest
//
//  Created by Ben Davis on 9/20/24.
//

import SwiftUI

struct ContentView: View {
    @State private var date: Date = Date()
    @State private var clockFrame: CGRect = .zero
    
    @State private var clockDesign = ClockDesign()
    
    let clockSize: CGFloat = 300
    @State private var clockID = UUID()
    var body: some View {
        VStack {
            Spacer()
            ClockView(clockDesign: self.clockDesign, size: self.clockSize, id: self.clockID)
                .onPreferenceChange(FramePreferenceKey.self, perform: { frame in
                    
                    let stops = [Gradient.Stop(color: .white, location: 0.50),
                                 Gradient.Stop(color: Color("ClockBackground"), location: 1.0)]
                    
                    let gradiant = Gradient(stops: stops)
                    
                    let radius = (clockSize / 2) - ((clockSize / 2) * 0.2)
                    clockDesign.background = .radialGradient(gradiant, center: CGPoint(x: frame.origin.x, y: frame.origin.y), startRadius: radius, endRadius: radius * 2)
                    
                    self.clockID = UUID()
                })
            
            Spacer()
            
            Label.init("Clock", systemImage: "clock")
                .padding()
        }
        .maxWidthCenter()
        .padding()

     
    }
}

#Preview {
    ContentView()
}
