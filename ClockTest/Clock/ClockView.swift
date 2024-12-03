//
//  ClockView.swift
//  ClockTest
//
//  Created by Ben Davis on 9/20/24.
//

import SwiftUI
import CoreFoundation

struct ClockView: View {
    
    @State private var date: Date = Date()
    @State private var clockFrame: CGRect = .zero
    
    let clockDesign: ClockDesign
    
    let size: CGFloat
    
    let id: UUID
    
    var body: some View {
        GeometryReader { proxy in

            ZStack {
                ClockBody(design: self.clockDesign, labels: ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"])
                TimelineView(.periodic(from: .now, by: 1)) { timeContext in
                    ClockAnimatable(date: timeContext.date,
                                    design: self.clockDesign)
                    .id(self.id)
                }
                .background {
                    Color.clear
                        .preference(key: FramePreferenceKey.self, value: proxy.frame(in: .local))
                }
            }
        }
        .frame(width: size, height: size)
    }
    

}

#Preview {
    ClockView(clockDesign: ClockDesign(), size: 300.0, id: UUID())
}
