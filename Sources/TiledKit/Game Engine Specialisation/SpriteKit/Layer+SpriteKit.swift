//
//  TiledLayer+SpriteKit.swift
//  Cascade Brexit Edition
//
//  Created on 12/04/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//
#if os(macOS) || os(tvOS) || os(watchOS) || os(iOS)
import SpriteKit

extension TileLayer {
    public func createNode()->SKNode{
        return SpriteKit.createNode(for: self, with: SpriteKit.textureCache)
    }

}

extension TileLayer {
 
}

public extension SKNode{
    public func centerChildren(){
        let size = calculateAccumulatedFrame()
        
        let dx = size.width / 2.0
        let dy = size.height / 2.0
        
        for child in children{
            child.position.x -= dx
            child.position.y -= dy
        }
    }
}
#endif
