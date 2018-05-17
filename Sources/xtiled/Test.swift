//
//  Test.swift
//  OysterKit
//
//

import Cocoa
import SpriteKit



func launchMacApp(with delegate:NSApplicationDelegate){
    
    autoreleasepool {
        // Even if we loading application manually we need to setup `Info.plist` key:
        // <key>NSPrincipalClass</key>
        // <string>NSApplication</string>
        // Otherwise Application will be loaded in `low resolution` mode.
        let app = NSApplication.shared
        app.setActivationPolicy(.regular)
        app.delegate = delegate
        app.run()
    }

}
