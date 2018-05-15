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

        if Thread.isMainThread {
            return SKTexture(imageNamed: url.lastPathComponent)
        }
        
        var texture : SKTexture!

        DispatchQueue.main.sync {
            texture = SKTexture(imageNamed: url.lastPathComponent)
        }
        
        return texture
    }
    
}
#endif
