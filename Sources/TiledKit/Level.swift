//
//  TiledLevel.swift
//  Cascade Brexit Edition
//
//  Created on 11/04/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

//TODO: Move into its own file
class DecodingContext{
    static var key : CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "TiledLevelDecodingContext")!
    }
    let customObjectTypes : [CustomObject.Type]
    var level : Level? = nil
    var layerPath = [Layer]()
    
    init(with customObjectTypes:[CustomObject.Type]){
        self.customObjectTypes = customObjectTypes
    }
}

protocol TiledDecodable : Decodable {
   
}

extension TiledDecodable {
    func decodingContext(_ decoder:Decoder)->DecodingContext{
        return decoder.userInfo.levelDecodingContext()
    }
}

public struct Level : TiledDecodable, LayerContainer, Propertied {
    public var parent : LayerContainer {
        return self
    }
    public var layers      = [Layer]()

    public let height      : Int
    public let width       : Int
    public let tileWidth   : Int
    public let tileHeight  : Int
    public var properties  = [String:Literal]()
    fileprivate let tileSetReferences    : [TileSetReference]
    fileprivate var tileSets = [TileSet]()
    public var tiles = [Int : TileSet.Tile]()
    
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
        decodingContext(decoder).level = self
        
        for tileSetReference in tileSetReferences {
            let tileSet = TileSetCache.tileSet(from: tileSetReference)
            tileSets.append(tileSet)
            for (lid,tile) in tileSet.tiles {
                tiles[tileSetReference.firstGID+lid] = tile
            }
        }

        //Import to set the level context before decoding layers
        layers.append(contentsOf: try Level.decodeLayers(container))

        //Now build all the custom objects
        for objectLayer in getObjectLayers(recursively: true) as [ObjectLayer]{
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
            let decodingContext = DecodingContext(with: customObjectTypes)
            jsonDecoder.userInfo[DecodingContext.key] = decodingContext
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
    
    enum CodingKeys : String, CodingKey {
        case height, width, layers, properties
        case tileWidth  = "tilewidth"
        case tileHeight = "tileheight"
        case tileSets = "tilesets"
    }
}

extension Dictionary where Key == CodingUserInfoKey {
    func levelDecodingContext()->DecodingContext{
        return (self[DecodingContext.key] as? DecodingContext) ?? DecodingContext(with: [])

    }
}
