//
//  TiledLevel+SpriteKit.swift
//  Cascade Brexit Edition
//
//  Created on 13/04/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//
#if os(macOS) || os(tvOS) || os(watchOS) || os(iOS)
import SpriteKit

extension Level {
    var allTextures : [Int : SKTexture] {
        return tiles.mapValues({$0.texture})
    }
}
#endif
