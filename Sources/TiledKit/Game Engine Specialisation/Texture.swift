//
//  Texture.swift
//  OysterKit
//
//

import Foundation

public protocol Texture {
    static func cache(from path:String)->Self
}

public struct TextureCache<EngineTexture:Texture>{
    private var cache = [Int:EngineTexture]()
    
    subscript(_ gid: Int)->EngineTexture?{
        get{
            return cache[gid]
        }
        set{
            cache[gid] = newValue
        }
    }
}


