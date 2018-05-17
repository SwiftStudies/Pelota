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
    
    @discardableResult
    static func texture(_ tile:TileSet.Tile)->Texture{
        if let cached = Self.textureCache[tile.identifier]{
            return cached
        }
        let loadedTexture : Texture
        
        let tileSet = require(tile.tileSet, or: "Tile does not have a tileset")
        
        if case let TileSetType.sheet(sheet) = tileSet.type {
            
            let cachedTexture : Texture
            
            if let alreadyCachedTexture = texture(Identifier(stringLiteral: sheet.imagePath)){
                cachedTexture = alreadyCachedTexture
            } else {
                cachedTexture = Texture.cache(from: sheet.imagePath) as! Texture
                Self.textureCache[Identifier(stringLiteral:sheet.imagePath)] = cachedTexture
            }
            
            let position = require(tile.position, or: "Sheet based tile has no position")
            
            loadedTexture = cachedTexture.subTexture(at: (Int(position.x), Int(position.y)), with: (width:tileSet.tileWidth, height: tileSet.tileHeight)) as! Texture

        } else if let path = tile.path {
            loadedTexture = (Texture.cache(from: path) as! Texture)
        } else {
            fatalError("Tile has no path and is not in a sheet")
        }
        
        textureCache[tile.identifier] = loadedTexture
        return loadedTexture
    }
    
    static func cacheTextures(from level:Level){
        for tile in level.tiles.values {
            texture(tile)
        }
    }
    

}

public protocol TextureType {
    //TODO: This should return Self, but then non-final conforming classes are required to return
    //Self... which they can't do
    static func cache(from path:String)->TextureType
    func subTexture(at:(x:Int,y:Int), with dimensions:(width:Int, height:Int))->TextureType
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


