//
//  Texture+SKTexture.swift
//  TiledKit
//
//
#if os(macOS) || os(tvOS) || os(watchOS) || os(iOS)
import SpriteKit

extension SKTexture : TextureType {
    public static func cache(from path: String) -> TextureType {
        let url = URL(fileURLWithPath: path)
        
        return SKTexture(imageNamed: url.lastPathComponent)
    }
    
}
#endif
