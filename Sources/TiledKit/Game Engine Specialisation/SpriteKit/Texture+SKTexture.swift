//
//  Texture+SKTexture.swift
//  TiledKit
//
//  Created by Nigel Hughes on 11/05/2018.
//
#if os(macOS) || os(tvOS) || os(watchOS) || os(iOS)
import SpriteKit

extension SKTexture : Texture {
    public static func cache(from path:String)->SKTexture{
        let url = URL(fileURLWithPath: path)
        
        return SKTexture(imageNamed: url.lastPathComponent)
    }
    
}

typealias SKLevel = TiledLevel<SKTexture>

#endif
