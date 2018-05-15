//
//  TiledLevel.swift
//  Cascade Brexit Edition
//
//  Created on 11/04/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

public protocol GameEngine {
    associatedtype Texture   : TextureType
    
    init()
    var textureCache : TextureCache<Texture> {get set}
}

class DecodingContext<Engine:GameEngine>{
    static var key : CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "TiledLevelDecodingContext")!
    }
    let customObjectTypes : [CustomObject.Type]
    var level : Level<Engine>? = nil
    var layerPath = [Layer<Engine>]()
    let engine : Engine
    
    init(with customObjectTypes:[CustomObject.Type], with engine:Engine){
        self.customObjectTypes = customObjectTypes
        self.engine = engine
    }
}

public struct Level<Engine:GameEngine> : Decodable, LayerContainer, Propertied {
    public func parent<E>() -> LayerContainerReference<E>? where E : GameEngine {
        return LayerContainerReference<E>.level(level: self as! Level<E>)
    }
    
    public func layers<E>() -> [Layer<E>] where E : GameEngine {
        return allLayers as! [Layer<E>]
    }
    
    public var engine      : Engine
    public let height      : Int
    public let width       : Int
    public let tileWidth   : Int
    public let tileHeight  : Int
    public var properties  = [String:Literal]()
    public var allLayers      = [Layer<Engine>]()
    fileprivate let tileSetReferences    : [TileSetReference<Engine>]
    fileprivate var tileSets = [TileSet<Engine>]()
    
    public var tiles = [Int : TileSet<Engine>.Tile]()
    
    public init(){
        height = 0
        width = 0
        tileWidth = 0
        tileHeight = 0
        tileSetReferences = []
        engine = Engine()
    }
    
    func decodingContext(_ decoder:Decoder)->DecodingContext<Engine>{
        return decoder.userInfo.levelDecodingContext()
    }
    
    public init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        engine = decoder.userInfo.levelDecodingContext().engine
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        tileWidth = try container.decode(Int.self, forKey: .tileWidth)
        tileHeight = try container.decode(Int.self, forKey: .tileHeight)
        tileSetReferences = try container.decode([TileSetReference].self, forKey: .tileSets)
        properties = try decode(from: decoder)
        decodingContext(decoder).level = self
        
        for tileSetReference in tileSetReferences {
            let tileSet = TileSet<Engine>(fromReference: tileSetReference)
            tileSets.append(tileSet)
            for (lid,tile) in tileSet.tiles {
                tiles[tileSetReference.firstGID+lid] = tile
            }
        }
        cacheTextures()

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
            let decodingContext = DecodingContext<Engine>(with: customObjectTypes, with: Engine())
            jsonDecoder.userInfo[DecodingContext<Engine>.key] = decodingContext
            let loadedLevel = try jsonDecoder.decode(Level.self, from: data)
            self.engine = loadedLevel.engine
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
        for tile in tiles {
            //TODO: Should not have to do this cast but see the issue documented on ```Texture``` protocol declaration
            engine.textureCache[tile.key] = (Engine.Texture.cache(from: tile.value.path) as! Engine.Texture)
        }
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
        return (self[DecodingContext<Engine>.key] as? DecodingContext<Engine>) ?? DecodingContext<Engine>(with: [], with: Engine())

    }
}
