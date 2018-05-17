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

public extension SKNode{
    convenience public init(from tileLayer:TileLayer, withTexturesIn textureCache:TextureCache<SKTexture> = SpriteKit.textureCache){
        let level = tileLayer.level
        
        let pixelWidth = level.width * level.tileWidth
        let pixelHeight = level.height * level.tileHeight
        
        self.init()
        
        name = String(tileLayer.name)
        
        for y in 0..<tileLayer.height {
            for x in 0..<tileLayer.width {
                let textureGid = tileLayer[x,y]
                guard textureGid != 0 else {
                    continue
                }
                
                
                let texture = textureCache[level.tiles[textureGid]!.identifier]
                
                let spriteNode = SKSpriteNode(texture: texture)
                spriteNode.position = CGPoint(x:(x*level.tileWidth+tileLayer.offset.x) - pixelWidth >> 1, y:(-y*level.tileHeight-tileLayer.offset.y) + pixelHeight >> 1)
                spriteNode.position.x += spriteNode.size.width / 2
                spriteNode.position.y += (spriteNode.size.height / 2) - CGFloat(level.tileHeight)
                addChild(spriteNode)
            }
        }
        
    }
    
    convenience public init(from groupLayer:GroupLayer, withTexturesIn textureCache:TextureCache<SKTexture> = SpriteKit.textureCache){
        self.init()
        for layer in groupLayer.layers{
            if let layer = layer as? GroupLayer {
                addChild(SKNode(from: layer, withTexturesIn: textureCache))
            } else if let layer = layer as? TileLayer{
                addChild(SKNode(from: layer, withTexturesIn: textureCache))
            } else if let layer = layer as? ObjectLayer {
                print("ERROR: I don't know how to autogenerate object layers yet")
            }
        }
    }
    
    
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
