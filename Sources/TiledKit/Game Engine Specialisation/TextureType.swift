//
//  Texture.swift
//  OysterKit
//
//

import Foundation

public protocol TextureType {
    //TODO: This should return Self, but then non-final conforming classes are required to return
    //Self... which they can't do
    static func cache(from path:String)->TextureType
}

public struct TextureCache<EngineTexture:TextureType>{
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


