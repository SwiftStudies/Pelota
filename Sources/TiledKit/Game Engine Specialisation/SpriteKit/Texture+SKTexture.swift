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
        print("WARNING: Switching to main thread in order to load a texture. This will be slow if you are loading many textures at the same time")
        var texture : SKTexture!

        DispatchQueue.main.sync {
            texture = SKTexture(imageNamed: url.lastPathComponent)
        }
        print("WARNING: Returning to background thread. This message is intended to annoy you into resolving the issue. ")

        return texture
    }
    
}
#endif
