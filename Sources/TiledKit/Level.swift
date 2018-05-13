//
//  TiledLevel.swift
//  Cascade Brexit Edition
//
//  Created on 11/04/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

//public enum GenericContainer<Engine:GameEngine> : LayerContainer {
//    typealias LayerContainer.Engine = Engine
//
//    case    level(level:Level<Engine>),
//            group(group:GroupLayer<Engine>)
//    
//    public var parent: Engine.Container{
//        switch self{
//        case .level(let level):
//            return level
//        case .group(let group):
//            return group.layers
//        }
//    }
//    
//    public var layers: [Layer<Engine>]{
//        switch self
//    }
//    
//    
//}

public protocol GameEngine {
    associatedtype Texture   : TextureType
}

class DecodingContext<Engine:GameEngine>{
    static var key : CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "TiledLevelDecodingContext")!
    }
    let customObjectTypes : [CustomObject.Type]
    var level : Level<Engine>? = nil
    var layerPath = [Layer<Engine>]()
    
    init(with customObjectTypes:[CustomObject.Type]){
        self.customObjectTypes = customObjectTypes
    }
}

public struct Level<Engine:GameEngine> : Decodable, LayerContainer, Propertied {
    public func parent<E>() -> LayerContainerReference<E>? where E : GameEngine {
        return LayerContainerReference<E>.level(level: self as! Level<E>)
    }
    
    public func layers<E>() -> [Layer<E>] where E : GameEngine {
        return allLayers as! [Layer<E>]
    }
    
    public let height      : Int
    public let width       : Int
    public let tileWidth   : Int
    public let tileHeight  : Int
    public var properties  = [String:Literal]()
    public var allLayers      = [Layer<Engine>]()
    fileprivate let tileSetReferences    : [TileSetReference<Engine>]
    fileprivate var tileSets = [TileSet<Engine>]()
    var textures    : TextureCache<Engine.Texture>? = nil
    
    public var tiles = [Int : TileSet<Engine>.Tile]()
    
    public init(){
        height = 0
        width = 0
        tileWidth = 0
        tileHeight = 0
        tileSetReferences = []
    }
    
    func decodingContext(_ decoder:Decoder)->DecodingContext<Engine>{
        return decoder.userInfo.levelDecodingContext()
    }
    
    public init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        tileWidth = try container.decode(Int.self, forKey: .tileWidth)
        tileHeight = try container.decode(Int.self, forKey: .tileHeight)
        tileSetReferences = try container.decode([TileSetReference].self, forKey: .tileSets)
        properties = try decode(from: decoder)
        
        for tileSetReference in tileSetReferences {
            let tileSet = TileSet<Engine>(fromReference: tileSetReference)
            tileSets.append(tileSet)
            for (lid,tile) in tileSet.tiles {
                tiles[tileSetReference.firstGID+lid] = tile
            }
        }

        //Import to set the level context before decoding layers
        allLayers.append(contentsOf: try Level.decodeLayers(container))

        //Now build all the custom objects
        for objectLayer in getObjectLayers(recursively: true) as [ObjectLayer<Engine>]{
            for object in objectLayer.objects {
                object.type = CustomObjectFactory.make(for: object, with: decodingContext(decoder).customObjectTypes)
            }
        }
    }
    
    public init(fromFile file:String, using customObjectTypes:[CustomObject.Type] = []){
        let url : URL
        
        if let bundleUrl = Bundle.main.url(forResource: file, withExtension: "json") {
            url = bundleUrl
        } else {
            url = URL(fileURLWithPath: file)
        }
        
        if !FileManager.default.fileExists(atPath: url.path){
            fatalError("Could not find level file \(file)")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load \(file) as data")
        }
        
        do {
            let jsonDecoder = JSONDecoder()
            let decodingContext = DecodingContext<Engine>(with: customObjectTypes)
            jsonDecoder.userInfo[DecodingContext<Engine>.key] = decodingContext
            let loadedLevel = try jsonDecoder.decode(Level.self, from: data)
            self.height = loadedLevel.height
            self.width  = loadedLevel.width
            self.tileWidth = loadedLevel.tileWidth
            self.tileHeight = loadedLevel.tileHeight
            self.properties = loadedLevel.properties
            self.allLayers = loadedLevel.allLayers
            self.tileSetReferences = loadedLevel.tileSetReferences
            self.tileSets = loadedLevel.tileSets
            self.tiles = loadedLevel.tiles
        } catch {
            fatalError("\(error)")
        }
    }
    
    mutating func cacheTextures(){
        var textures = TextureCache<Engine.Texture>()
        for tile in tiles {
            //TODO: Should not have to do this cast but see the issue documented on ```Texture``` protocol declaration
            textures[tile.key] = (Engine.Texture.cache(from: tile.value.path) as! Engine.Texture)
        }
        self.textures = textures
    }


    enum CodingKeys : String, CodingKey {
        case height, width, layers, properties
        case tileWidth  = "tilewidth"
        case tileHeight = "tileheight"
        case tileSets = "tilesets"
    }
}

extension Dictionary where Key == CodingUserInfoKey {
    func levelDecodingContext<Engine:GameEngine>()->DecodingContext<Engine>{
        return (self[DecodingContext<Engine>.key] as? DecodingContext<Engine>) ?? DecodingContext<Engine>(with: [])

    }
}
