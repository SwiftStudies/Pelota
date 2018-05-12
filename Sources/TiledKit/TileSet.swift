//
//  TileSet.swift
//  Cascade Brexit Edition
//
//  Created on 11/04/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import SpriteKit

struct TileSetReference<Engine:GameEngine> : Decodable where Engine.Loader.Engine == Engine {
    internal let firstGID    : Int
    fileprivate let file        : String
    
    var tileSet : TileSet<Engine> {
        return TileSet<Engine>(fromReference: self)
    }
    
    enum CodingKeys : String, CodingKey {
        case firstGID = "firstgid", file = "source"
    }
}

var tileSetCache = [String : Any]()

public struct TileSet<Engine:GameEngine> : Decodable where Engine.Loader.Engine == Engine, Engine.Container.Engine == Engine {
    public let tileWidth : Int
    public let tileHeight : Int
    public var tiles = [Int:Tile]()
    
    public enum CodingKeys : String, CodingKey {
        case tiles
        case tileWidth = "tilewidth"
        case tileHeight = "tileheight"
    }
    
    public class Tile: Decodable, LayerContainer {
        
        public var parent: Engine.Container {
            return self as! Engine.Container
        }
        
        public var layers: [Layer<Engine>] {
            if let objects = objects {
                return [objects]
            }
            return []
        }
        
        public let path    : String
        public let objects : ObjectLayer<Engine>?
        public var tileSet : TileSet? = nil
        
        enum CodingKeys : String, CodingKey {
            case image, objects = "objectgroup"
        }
        
        public required init(from decoder: Decoder) throws{
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            path = try container.decode(String.self, forKey: CodingKeys.image)
            
            objects = try container.decodeIfPresent(ObjectLayer.self, forKey: .objects)
        }
    }
    
    public init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        tileWidth = try container.decode(Int.self, forKey: .tileWidth)
        tileHeight = try container.decode(Int.self, forKey: .tileHeight)
        
        //Import to set the level context before decoding tiles as they can contain layers
        let level = Level<Engine>()
        decoder.userInfo.levelDecodingContext().level = level
        
        try DispatchQueue.main.sync {
            self.tiles = try container.decode([Int : Tile].self, forKey: .tiles)
        }
        
        for tile in tiles.values {
            tile.tileSet = self
        }
        
    }
    
    public init(from file:String){
        if let cachedTileSet = tileSetCache[file]  as? TileSet<Engine>{
            self.tiles = cachedTileSet.tiles
            self.tileHeight = cachedTileSet.tileHeight
            self.tileWidth = cachedTileSet.tileWidth
            return
        }
        
        guard let url = Bundle.main.url(forResource: file, withExtension: nil) else {
            fatalError("Could not find \(file).json in bundle")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not load \(file) into data")
        }
        
        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.userInfo[DecodingContext<Engine>.key] = DecodingContext<Engine>(with: [])
            
            let loaded = try jsonDecoder.decode(TileSet.self, from: data)
            tileSetCache[file] = loaded
            
            self.tiles = loaded.tiles
            self.tileWidth = loaded.tileWidth
            self.tileHeight = loaded.tileHeight
        } catch {
            fatalError("Could not decode JSON \(error)")
        }
    }
    
    init(fromReference reference:TileSetReference<Engine>){
        let source = reference.file
        let name = NSString(string:source).lastPathComponent
        
        self.init(from: name)
    }
}
