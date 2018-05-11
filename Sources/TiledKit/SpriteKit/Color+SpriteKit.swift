//
//  Color+SpriteKit.swift
//  Cascade Brexit Edition
//
//  Created on 01/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//
#if os(macOS) || os(tvOS) || os(watchOS) || os(iOS)

import SpriteKit

extension Color {
    var skColor : SKColor {
        let red = CGFloat(self.red) / 255
        let green = CGFloat(self.green) / 255
        let blue = CGFloat(self.blue) / 255
        let alpha = CGFloat(self.alpha) / 255
        
        #if os(macOS)
            return SKColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
        #else
            return SKColor(red: red, green: green, blue: blue, alpha: alpha)
        #endif
    }
}
#endif
