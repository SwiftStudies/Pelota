//
//  TiledLevel.swift
//  TiledKit
//
//

import Pelota

public struct TiledLevel<T:Texture>{
    private let level       : Level
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
            //TODO: Should not have to do this cast but see the issue documented on ```Texture``` protocol declaration
            textures[tile.key] = (T.cache(from: tile.value.path) as! T)
        }
        self.textures = textures
    }
    
    var height      : Int{
        return level.height
    }
    
    var width       : Int {
        return level.width
    }
    
    var tileWidth   : Int {
        return level.tileWidth
    }
    
    var tileHeight  : Int {
        return level.tileHeight
    }
    
    var properties  : [String:Literal]{
        return level.properties
    }
    
    public var layers      : [Layer]{
        return level.layers
    }

}
