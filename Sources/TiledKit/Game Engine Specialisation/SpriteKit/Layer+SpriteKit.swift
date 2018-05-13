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
    public func createNode(for level:Level<Engine>)->SKNode{
        let pixelWidth = level.width * level.tileWidth
        let pixelHeight = level.height * level.tileHeight
        
        let allTextures = level.engine.textureCache
        
        
        let node = SKNode()
        
        for y in 0..<height {
            for x in 0..<width {
                let texture = self[x,y]
                guard texture != 0 else {
                    continue
                }
                
                let spriteNode = SKSpriteNode(texture: (allTextures[texture] as! SKTexture))
                spriteNode.position = CGPoint(x:(x*level.tileWidth+offset.x) - pixelWidth >> 1, y:(-y*level.tileHeight-offset.y) + pixelHeight >> 1)
                spriteNode.position.x += spriteNode.size.width / 2
                spriteNode.position.y += (spriteNode.size.height / 2) - CGFloat(level.tileHeight)
                node.addChild(spriteNode)
            }
        }
        
        return node
    }
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
