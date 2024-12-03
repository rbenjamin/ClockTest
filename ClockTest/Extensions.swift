//
//  Extensions.swift
//  ClockTest
//
//  Created by Ben Davis on 9/24/24.
//

import Foundation
import SwiftUI



extension CGRect {

    init(frame: CGRect, insetRatio: Double) {
        let insetWidth = frame.size.width * insetRatio
        let insetHeight = frame.size.height * insetRatio
        self.init()
        self.origin = CGPoint(x: frame.origin.x - (insetWidth / 2.0), y: frame.origin.y - (insetHeight / 2.0))
        self.size = CGSize(width: insetWidth, height: insetHeight)
        
    }

}

struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = CGRect(origin: .zero, size: .zero)
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

struct MaxWidth: ViewModifier {
    let alignment: Alignment
    func body(content: Content) -> some View {
        content.frame(maxWidth: .infinity, alignment: self.alignment)
    }
}
extension View {
    func maxWidth(alignment: Alignment) -> some View {
        modifier(MaxWidth(alignment: alignment))
    }
    /**
        Centers the view contents in the modified view's frame.
    */
    func maxWidthCenter() -> some View {
        modifier(MaxWidth(alignment: .center))
    }
    
    func maxWidthLeading() -> some View {
        modifier(MaxWidth(alignment: .leading))
    }

}
