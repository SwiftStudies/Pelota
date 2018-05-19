//
//  main.swift
//  Pelota
//
//  Created on 11/05/2018.
//

import Cocoa
import SpriteKit
import TiledKit
import Pelota

class MainMenu: NSMenu {
    private lazy var applicationName = ProcessInfo.processInfo.processName
    
    init() {
        super.init(title: "")
        let appMenuItem = NSMenuItem()
        appMenuItem.submenu = appMenu
        addItem(appMenuItem)
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    @objc
    func quitAction(sender:Any?){
        print("So sad")
        NSApplication.shared.terminate(nil)
    }
    
    private var appMenu: NSMenu {
        let menu = NSMenu(title: "")
        let quitItem = NSMenuItem(title: "Quit \(ProcessInfo.processInfo.processName)", action: #selector(self.quitAction(sender:)), keyEquivalent: "q")
        quitItem.isEnabled = true
        menu.addItem(quitItem)
        return menu
    }
    
}


class AppDelegate : NSObject, NSApplicationDelegate, NSWindowDelegate {
    lazy var window = NSWindow(contentRect: NSMakeRect(100, 100, 200, 200), styleMask: [.titled,.closable, .resizable], backing: .buffered, defer: false, screen:nil)
    
    var skView : SKView!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        skView = SKView(frame: window.frame)
        
        let level = Level(fromFile: "/Volumes/Personal/SPM/Pelota/Resources/TestData/Dungeon.json", for: SpriteKit.self)
        
        window.setContentSize(NSSize(width: level.width*level.tileWidth, height: level.height*level.tileHeight))
        window.center()
        
        let scene = SKScene(size: CGSize(width: 320, height: 256))
        

        for layer in level.layers {
            if let groupLayer = layer as? GroupLayer {
                scene.addChild(SKNode(from: groupLayer))
            } else if let tileLayer = layer as? TileLayer{
                scene.addChild(SKNode(from: tileLayer))
            }
        }
        
        skView.presentScene(scene)
        
        window.delegate = self
        window.contentView = skView
        
        // Ensure the aspect ratio is respected by the scene in the view
        scene.scaleMode = .aspectFit
        // And that the resize increments don't cause odd rounding for tile sheets
        window.resizeIncrements = CGSize(width: level.tileWidth, height: level.tileHeight)
        
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        window.makeKey()
        NSApplication.shared.mainMenu = MainMenu()
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(nil)
    }
    
}

launchMacApp(with: AppDelegate())
