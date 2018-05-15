//
//  Texture.swift
//  OysterKit
//
//

import Pelota

public protocol GameEngine {
    associatedtype Texture : TextureType
    
    init()
    
    static var textureCache : TextureCache<Texture> {get set}
}

extension GameEngine {
    static func texture(_ identifier:Identifier)->Texture?{
        return Self.textureCache[identifier]
    }
    
    static func texture(_ tile:TileSet.Tile)->Texture{
        if let cached = Self.textureCache[Identifier(stringLiteral: tile.path)]{
            return cached
        }
        let loadedTexture = (Texture.cache(from: tile.path) as! Texture)
        textureCache[tile.identifier] = loadedTexture
        return loadedTexture
    }
    
    static func cacheTextures(from level:Level){
        for tile in level.tiles.values {
            textureCache[tile.identifier] = (Texture.cache(from: tile.path) as! Texture)
        }
    }
    

}

public protocol TextureType {
    //TODO: This should return Self, but then non-final conforming classes are required to return
    //Self... which they can't do
    static func cache(from path:String)->TextureType
}

public class TextureCache<Texture:TextureType>{
    private var cache = [Identifier:Texture]()
    
    public init(){
        
    }
    
    public var allIdentifiers : [Identifier] {
        return cache.map({$0.key})
    }
    
    public var count : Int {
        return cache.count
    }
    
    public subscript(_ identifier: Identifier)->Texture?{
        get{
            return cache[identifier]
        }
        set{
            cache[identifier] = newValue
        }
    }

}


