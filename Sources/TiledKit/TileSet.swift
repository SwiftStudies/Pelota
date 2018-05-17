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

public enum TileSetType {
    case files
    case sheet(tileSheet:TileSheet)
}

public struct TileSheet : Decodable {
    let imagePath : String
    let imageWidth : Int
    let imageHeight : Int
    let margin : Int
    let spacing : Int
    let tileCount : Int
    let transparentColor : Color
    let columns : Int
    
    
    private enum CodingKeys : String, CodingKey {
        case imageWidth = "imagewidth", imageHeight = "imageheight", margin, spacing, tileCount="tilecount", transparentColor = "transparentcolor", columns, imagePath = "image"
    }
    
    func createTiles(for tileSet:TileSet, with data:[Int:TileSet.Tile], in container:LayerContainer)->[Int:TileSet.Tile]{
        var tiles = [Int:TileSet.Tile]()

        for tileIndex in 0..<tileCount {
            let row     = tileIndex / columns
            let column  = tileIndex % columns
            
            let y = (row * tileSet.tileHeight) +
                (row * spacing) +
                ((row * 2 * margin ) + margin)
            let x = (column * tileSet.tileWidth) +
                (column * spacing) +
                ((column * 2 * margin ) + margin)
                    
            
            let newTile = TileSet.Tile(tileIndex, from: self, for: tileSet, at: (x,y), in: container)
            
            if let additionalTileData = data[tileIndex] {
                newTile.objects = additionalTileData.objects
            }
            
            tiles[tileIndex] = newTile
        }
        return tiles
    }
}

public struct TileSet : TiledDecodable{
    public var name : String
    public var tileWidth : Int
    public var tileHeight : Int
    public var tiles = [Int:Tile]()
    public var type : TileSetType
    
    public enum CodingKeys : String, CodingKey {
        case tiles
        case tileWidth = "tilewidth"
        case tileHeight = "tileheight"
        case name
        case image
    }
    
    public init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        tileWidth = try container.decode(Int.self, forKey: .tileWidth)
        tileHeight = try container.decode(Int.self, forKey: .tileHeight)
        name = try container.decode(String.self, forKey: .name)
        
        //Import to set the level context before decoding tiles as they can contain layers
        let level = Level()
        decoder.userInfo.levelDecodingContext().level = level
        
        // Create the tiles, we first need to determine if this is a
        // sheet type or a collection of images
        if container.contains(.image){
            let spec = try TileSheet(from: decoder)
            type = .sheet(tileSheet: spec)
            // Needed for layers and animations etc
            let tilesData = try container.decode([Int:Tile].self, forKey: .tiles)
            tiles = spec.createTiles(for:self, with: tilesData, in: level)
        } else {
            //It's individual files
            type = .files
            self.tiles = try container.decode([Int : Tile].self, forKey: .tiles)
            for tile in tiles.values {
                tile.tileSet = self
            }
        }
    }
    
    public class Tile: TiledDecodable, LayerContainer {
        public var identifier : Identifier
        public var parent : LayerContainer
        public let path    : String?
        public var objects : ObjectLayer?
        public var tileSet : TileSet? = nil
        public let position : Position?
        public var layers : [Layer] {
            if let objectLayer = objects {
                return [objectLayer]
            }
            return []
        }

        enum CodingKeys : String, CodingKey {
            case image, objects = "objectgroup"
        }
        
        public required init(_ index:Int, from sheet:TileSheet, for set:TileSet, at location: (x:Int,y:Int), in container:LayerContainer){
            identifier = Identifier(stringLiteral: "\(sheet.imagePath):\(index)")
            path = nil
            tileSet = set
            objects = nil
            position = Position(x:location.x,y:location.y)
            parent = container
        }
        
        public required init(from decoder: Decoder) throws{
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let path = try container.decodeIfPresent(String.self, forKey: CodingKeys.image){
                self.path = path
                identifier = Identifier(stringLiteral: path)
            } else {
                path = nil
                identifier = Identifier(integerLiteral: 0)
            }
            parent = (decoder.userInfo[DecodingContext.key] as! DecodingContext).level!
            objects = try container.decodeIfPresent(ObjectLayer.self, forKey: .objects)
            position = nil
        }
        
        func texture<Engine:GameEngine>(for:Engine.Type)->Engine.Texture{
            return Engine.textureCache[identifier] ?? Engine.texture(self)
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
            self.type = loaded.type
        } catch {
            fatalError("Could not decode JSON \(error)")
        }
    }
    
    public init(named name:String, tileWidth:Int, tileHeight:Int, of type:TileSetType){
        self.name = name
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.type = type
    }
}
