//
//  Texture.swift
//  OysterKit
//
//

import Foundation

public protocol Texture {
    //TODO: This should return Self, but then non-final conforming classes are required to return
    //Self... which they can't do
    static func cache(from path:String)->Texture
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


