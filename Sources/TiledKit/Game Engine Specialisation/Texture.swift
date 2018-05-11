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

public struct TiledLevel<T:Texture>{
    let level       : Level
    var textures    : TextureCache<T>? = nil
    
    init(fromFile   fileName:String, using customTypes:[CustomObject.Type] = [], managedBy loader:LevelLoader? = nil){
        level = Level(fromFile: fileName, using: customTypes, managedBy: loader)
    }
    
    init(levelNamed resourceName:String, using customTypes:[CustomObject.Type] = [], managedBy loader:LevelLoader? = nil){
        level = Level(fromFile: resourceName, using: customTypes, managedBy: loader)
    }
    
    mutating func cacheTextures(){
        var textures = TextureCache<T>()
        for tile in level.tiles {
            textures[tile.key] = T.cache(from: tile.value.path)
        }
        self.textures = textures
    }
}
