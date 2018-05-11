//
//  TiledLevel.swift
//  Cascade Brexit Edition
//
//  Created on 11/04/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

public protocol LevelLoader {
    func willLoadLayers(into level:Level)
    func didLoadLayers(from level:Level)
    
}

public struct Level : Decodable, LayerContainer, Propertied {
    public var parent: LayerContainer {
        return self
    }
    
    let height      : Int
    let width       : Int
    let tileWidth   : Int
    let tileHeight  : Int
    var properties  = [String:Literal]()
    public var layers      = [Layer]()
    fileprivate let tileSetReferences    : [TileSetReference]
    fileprivate var tileSets = [TileSet]()
    
    var tiles = [Int : TileSet.Tile]()
    
    public init(){
        height = 0
        width = 0
        tileWidth = 0
        tileHeight = 0
        tileSetReferences = []
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
            let tileSet = TileSet(fromReference: tileSetReference)
            tileSets.append(tileSet)
            for (lid,tile) in tileSet.tiles {
                tiles[tileSetReference.firstGID+lid] = tile
            }
        }

        //Import to set the level context before decoding layers
        decoder.userInfo.levelDecodingContext.level = self
        decoder.userInfo.levelDecodingContext.levelLoader?.willLoadLayers(into: self)
        layers.append(contentsOf: try Level.decodeLayers(container))
        decoder.userInfo.levelDecodingContext.levelLoader?.didLoadLayers(from: self)

        //Now build all the custom objects
        for objectLayer in getObjectLayers(recursively: true){
            for object in objectLayer.objects {
                object.type = CustomObjectFactory.make(for: object, with: decoder.userInfo.levelDecodingContext.customObjectTypes, andLoader: decoder.userInfo.levelDecodingContext.levelLoader)
            }
        }
    }
    
    init(fromFile file:String, using customObjectTypes:[CustomObject.Type] = [], managedBy levelLoader:LevelLoader? = nil){
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
            jsonDecoder.userInfo[DecodingContext.key] = DecodingContext(with: customObjectTypes, managedBy: levelLoader)
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
    
    class DecodingContext {
        static let key = CodingUserInfoKey(rawValue: "TiledLevelDecodingContext")!
        let customObjectTypes : [CustomObject.Type]
        var level : Level? = nil
        var layerPath = [Layer]()
        var levelLoader : LevelLoader?
        
        init(with customObjectTypes:[CustomObject.Type], managedBy levelLoader : LevelLoader? = nil){
            self.customObjectTypes = customObjectTypes
            self.levelLoader = levelLoader
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
    var levelDecodingContext : Level.DecodingContext {
        return (self[Level.DecodingContext.key] as? Level.DecodingContext) ?? Level.DecodingContext(with: [])
    }
}
