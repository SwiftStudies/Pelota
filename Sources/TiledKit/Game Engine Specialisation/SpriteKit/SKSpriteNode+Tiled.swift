//
//  SKSpriteNode+Tiled.swift
//  TiledKit
//
//

import Foundation

#if os(macOS) || os(tvOS) || os(watchOS) || os(iOS)
import SpriteKit
import Pelota

extension SKSpriteNode {
    convenience init(with tileObject:TileObject){
        let texture = SpriteKit.textureCache[tileObject.level.tiles[tileObject.gid]!.identifier]
        self.init(texture: texture)
        name = tileObject.name
        
        physicsBody = SKPhysicsBody.create(from: tileObject)
        
        userData = ["tileObject" :  self]
        
    }
}

#endif
