//
//  TileSet.swift
//  Cascade Brexit Edition
//
//  Created on 11/04/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import SpriteKit
import Pelota

class TileSetReference : Decodable{
    var identifier : Identifier? = nil
    let firstGID    : Int
    let file        : String
    
    init(with firstGid:Int, for tileSet:TileSet, in file:String){
        self.firstGID = firstGid
        identifier = Identifier(stringLiteral: tileSet.name)
        self.file = file
    }
    
    var tileSet : TileSet {
        return TileSetCache.tileSet(from: self)
    }
    
    enum CodingKeys : String, CodingKey {
        case firstGID = "firstgid", file = "source"
    }
}

public struct TileSet : TiledDecodable{
    public var name : String
    public var tileWidth : Int
    public var tileHeight : Int
    public var tiles = [Int:Tile]()
    
    public enum CodingKeys : String, CodingKey {
        case tiles
        case tileWidth = "tilewidth"
        case tileHeight = "tileheight"
        case name
    }
    
    public class Tile: TiledDecodable, LayerContainer {
        public var identifier : Identifier
        public var parent : LayerContainer
        public let path    : String
        public let objects : ObjectLayer?
        public var tileSet : TileSet? = nil
        public var layers : [Layer] {
            if let objectLayer = objects {
                return [objectLayer]
            }
            return []
        }

        enum CodingKeys : String, CodingKey {
            case image, objects = "objectgroup"
        }
        
        public required init(from decoder: Decoder) throws{
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            path = try container.decode(String.self, forKey: CodingKeys.image)
            parent = (decoder.userInfo[DecodingContext.key] as! DecodingContext).level!
            objects = try container.decodeIfPresent(ObjectLayer.self, forKey: .objects)
            identifier = Identifier(stringLiteral: path)
        }
    }
    
    public init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        tileWidth = try container.decode(Int.self, forKey: .tileWidth)
        tileHeight = try container.decode(Int.self, forKey: .tileHeight)
        name = try container.decode(String.self, forKey: .name)
        
        //Import to set the level context before decoding tiles as they can contain layers
        let level = Level()
        decoder.userInfo.levelDecodingContext().level = level
        
        try DispatchQueue.main.sync {
            self.tiles = try container.decode([Int : Tile].self, forKey: .tiles)
        }
        
        for tile in tiles.values {
            tile.tileSet = self
        }
        
    }
    
    init(from url:URL){
        let data = Data.withContentsInBundleFirst(url:url)
        
        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.userInfo[DecodingContext.key] = DecodingContext(with: [])
            
            let loaded = try jsonDecoder.decode(TileSet.self, from: data)
            
            self.tiles = loaded.tiles
            self.tileWidth = loaded.tileWidth
            self.tileHeight = loaded.tileHeight
            self.name = loaded.name
        } catch {
            fatalError("Could not decode JSON \(error)")
        }
    }
    
    public init(named name:String, tileWidth:Int, tileHeight:Int){
        self.name = name
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
    }
}
