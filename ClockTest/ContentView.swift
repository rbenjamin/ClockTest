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
    
    @State private var clockDesign = ClockView.ClockDesign()
    
    let clockSize: CGFloat = 300
    @State private var clockID = UUID()
    var body: some View {
        VStack {
            Spacer()
                GeometryReader { proxy in

                    TimelineView(.periodic(from: .now, by: 1)) { timeContext in
                        ClockView(date: timeContext.date,
                                  design: self.clockDesign)
                        .frame(width: clockSize, height: clockSize, alignment: .center)
                        .id(clockID)
                        .background {
                            Color.clear
                                .preference(key: FramePreferenceKey.self, value: proxy.frame(in: .local))
                        }
                        
                    }
                    .maxWidthCenter()

                }
            
            
            Spacer()
            
            Label.init("Clock", systemImage: "clock")
                .padding()
        }
        .padding()
        .onPreferenceChange(FramePreferenceKey.self, perform: { frame in
            // To use a radial gradient, we need a radius and frame.  We'll use a preference key to get the size from a geometry reader.
            let stops = [Gradient.Stop(color: .white, location: 0.50),
                         Gradient.Stop(color: Color("ClockBackground"), location: 1.0)]
            
            let gradiant = Gradient(stops: stops)
            
            let radius = (clockSize / 2) - ((clockSize / 2) * 0.2)
            
            clockDesign.background  = .radialGradient(gradiant, center: CGPoint(x: frame.origin.x, y: frame.origin.y), startRadius: radius, endRadius: radius * 2)
            
            self.clockID = UUID()
        })
     
    }
}

#Preview {
    ContentView()
}
