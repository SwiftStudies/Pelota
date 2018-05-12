//
//  TiledLevel.swift
//  Cascade Brexit Edition
//
//  Created on 11/04/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

public protocol LevelLoader {
    associatedtype  Engine : GameEngine where Engine.Container.Engine == Engine, Engine.Loader.Engine == Engine
}

public protocol GameEngine {
    associatedtype Texture   : TextureType
    associatedtype Loader    : LevelLoader
    associatedtype Container : LayerContainer
}

class DecodingContext<Engine:GameEngine> where Engine.Loader.Engine == Engine, Engine.Container.Engine == Engine{
    static var key : CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "TiledLevelDecodingContext")!
    }
    let customObjectTypes : [CustomObject.Type]
    var level : Level<Engine>? = nil
    var layerPath = [Layer<Engine>]()
    var levelLoader : Engine.Loader?
    
    init(with customObjectTypes:[CustomObject.Type], managedBy levelLoader : Engine.Loader? = nil){
        self.customObjectTypes = customObjectTypes
        self.levelLoader = levelLoader
    }
}

public struct Level<Engine:GameEngine> : Decodable, LayerContainer, Propertied where Engine == Engine.Loader.Engine, Engine.Container.Engine == Engine{
    public var parent: Engine.Container {
        return self as! Engine.Container
    }
    
    public let height      : Int
    public let width       : Int
    public let tileWidth   : Int
    public let tileHeight  : Int
    public var properties  = [String:Literal]()
    public var layers      = [Layer<Engine>]()
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
        layers.append(contentsOf: try Level.decodeLayers(container))

        //Now build all the custom objects
        for objectLayer in getObjectLayers(recursively: true){
            for object in objectLayer.objects {
                object.type = CustomObjectFactory.make(for: object, with: decodingContext(decoder).customObjectTypes, andLoader: decodingContext(decoder).levelLoader)
            }
        }
    }
    
    public init(fromFile file:String, using customObjectTypes:[CustomObject.Type] = [], managedBy levelLoader:Engine.Loader? = nil){
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
            let decodingContext = DecodingContext<Engine>(with: customObjectTypes, managedBy: levelLoader)
            jsonDecoder.userInfo[DecodingContext<Engine>.key] = decodingContext
            let loadedLevel = try jsonDecoder.decode(Level.self, from: data)
            self.height = loadedLevel.height
            self.width  = loadedLevel.width
            self.tileWidth = loadedLevel.tileWidth
            self.tileHeight = loadedLevel.tileHeight
            self.properties = loadedLevel.properties
            self.layers = loadedLevel.layers
            self.tileSetReferences = loadedLevel.tileSetReferences
            self.tileSets = loadedLevel.tileSets
            self.tiles = loadedLevel.tiles
        } catch {
            fatalError("\(error)")
        }
    }
    
    mutating func cacheTextures(){
        var textures = TextureCache<Engine.Texture>()
        for tile in level.tiles {
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
