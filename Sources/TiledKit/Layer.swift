//
//  Layers.swift
//  Cascade Brexit Edition
//
//  Created on 01/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

public class Layer: TiledDecodable, Propertied{
    public let name    : String
    public let visible : Bool
    public let opacity : Float
    public let x       : Int
    public let y       : Int
    
    let parent  : LayerContainer
    
    public var properties = [String : Literal]()
    
    var level : Level {
        return parent.level
    }
    
    enum CodingKeys : String, CodingKey {
        case name, visible, opacity, x, y, objects, layers
        case tileData  = "data"
        case tileWidth = "width"
        case tileHeight = "height"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        x = try container.decode(Int.self, forKey: .x)
        y = try container.decode(Int.self, forKey: .y)
        name = try container.decode(String.self, forKey: .name)
        visible = try container.decode(Bool.self, forKey: .visible)
        opacity = try container.decode(Float.self, forKey: .opacity)
        
        let decoderContext = decoder.userInfo[DecodingContext.key] as! DecodingContext
        
        if let layerStackTop = decoderContext.layerPath.last {
            parent = layerStackTop as! GroupLayer
        } else {
            parent = decoderContext.level!
        }
        properties = try decode(from: decoder)
    }
}

public class TileLayer : Layer{
    public let width : Int
    public let height : Int
    public let tiles : [Int]
    public let offset : (x:Int, y:Int)
    
    enum TiledCodingKeys : String, CodingKey {
        case tiles = "data", width, height,offsetx, offsety
    }
    
    required public init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: TiledCodingKeys.self)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        tiles = try container.decode([Int].self, forKey: .tiles)
        let offsetx = (try? container.decode(Int.self, forKey: .offsetx)) ?? 0
        let offsety = (try? container.decode(Int.self, forKey: .offsety)) ?? 0
        offset = (offsetx, offsety)
        try super.init(from: decoder)
        
        let decoderContext = level.decodingContext(decoder)
        decoderContext.layerPath.append(self)
        decoderContext.layerPath.removeLast()
    }
    
    public subscript(_ x:Int, _ y:Int)->Int{
        return tiles[x+y*width]
    }
}

public class ObjectLayer : Layer{
    public var objects = [Object] ()
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let decoderContext = level.decodingContext(decoder)
        decoderContext.layerPath.append(self)
        objects = try decodeObjects(from: try decoder.container(keyedBy: CodingKeys.self).nestedUnkeyedContainer(forKey: .objects), in: decoderContext)
        
        for tileObject in objects.compactMap({$0 as? TileObject}){
            tileObject.tile = decoder.userInfo.levelDecodingContext().level?.tiles[tileObject.gid]
        }
        
        decoderContext.layerPath.removeLast()
    }
}

public final class GroupLayer : Layer, LayerContainer{
    
    public var layers = [Layer]()
    
    enum LayerCodingKeys : String, CodingKey {
        case layers
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let decoderContext = level.decodingContext(decoder)
        
        decoderContext.layerPath.append(self)
        let layers : [Layer] = try Level.decodeLayers(decoder.container(keyedBy: Level.CodingKeys.self))
        self.layers.append(contentsOf: layers)
        decoderContext.layerPath.removeLast()
    }
}

