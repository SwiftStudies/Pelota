//
//  Object.swift
//  Cascade Brexit Edition
//
//  Created on 30/04/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

public protocol CustomObject {
    static var identifier : String { get }
    init?<Engine:GameEngine>(for object: Object<Engine>)
}

fileprivate var registeredCustomObjectTypes = [CustomObject.Type]()

enum CustomObjectFactory {
    static func make<Engine:GameEngine>(for object:Object<Engine>, with customObjectTypes:[CustomObject.Type])->CustomObject? {
        for type in customObjectTypes {
            if type.identifier == object.rawType ?? "" {
                return type.init(for: object)
            }
        }
        return nil
    }
}

public class Object<Engine:GameEngine> : Decodable, Propertied{
    internal enum ObjectDecodingError : Error {
        case notMyType      // A specialisation cannot decode
        case unknownType    // No specialisation can decode
    }
    private enum CodingKeys : String, CodingKey {
        case id, name, visible, x, y, type
    }
    
    public let id          : Int
    public let name        : String?
    public var type        : CustomObject?
    fileprivate let rawType : String?
    public let visible     : Bool
    public let x           : Float
    public let y           : Float
    public let parent      : ObjectLayer<Engine>
    
    public var properties  = [String:Literal]()
    
    public var level       : Level<Engine> {
        return parent.level 
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        //Standard stuff
        id      = try container.decode(Int.self, forKey: .id)
        name    = try container.decodeIfPresent(String.self, forKey: .name)
        visible = try container.decode(Bool.self, forKey: .visible)
        x       = try container.decode(Float.self, forKey: .x)
        y       = try container.decode(Float.self, forKey: .y)
        rawType = try container.decodeIfPresent(String.self, forKey: .type)
        
        parent = decoder.userInfo.levelDecodingContext().layerPath.last! as! ObjectLayer
        
        // Properties
        properties = try decode(from: decoder)
    }
}

class PointObject<Engine:GameEngine> : Object<Engine> {
    private enum CodingKeys : String, CodingKey {
        case point
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if try container.decodeIfPresent(Bool.self, forKey: .point) ?? false != true {
            throw ObjectDecodingError.notMyType
        }
        
        try super.init(from: decoder)
    }
}

public class RectangleObject<Engine:GameEngine> : Object<Engine>{
    private enum CodingKeys : String, CodingKey {
        case width, height, rotation
    }

    public let width       : Float
    public let height      : Float
    public let rotation    : Float
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if !(container.contains(.width) && container.contains(.height) && container.contains(.rotation)) {
            throw ObjectDecodingError.notMyType
        }
        
        width       = try container.decode(Float.self, forKey: .width)
        height      = try container.decode(Float.self, forKey: .height)
        rotation    = try container.decode(Float.self, forKey: .rotation)

        try super.init(from: decoder)
    }
}

class EllipseObject<Engine:GameEngine> : RectangleObject<Engine>{
    private enum CodingKeys : String, CodingKey {
        case ellipse
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if try container.decodeIfPresent(Bool.self, forKey: .ellipse) ?? false != true {
            throw ObjectDecodingError.notMyType
        }
        
        try super.init(from: decoder)
    }
}

public class TileObject<Engine:GameEngine> : RectangleObject<Engine>{
    private enum CodingKeys : String, CodingKey {
        case gid, tile
    }
    
    public let gid : Int
    public var tile    : TileSet<Engine>.Tile? = nil
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if !container.contains(.gid) {
            throw ObjectDecodingError.notMyType
        }
        
        gid = try container.decode(Int.self, forKey: .gid)
        
        try super.init(from: decoder)
    }
}

public class TextObject<Engine:GameEngine> : RectangleObject<Engine>{
    public struct TextProperties : Decodable{
        public let fontName : String
        public let fontSize : Int
        public let text     : String
        public let color    : Color
        
        enum CodingKeys : String, CodingKey {
            case    fontName = "fontfamily",
            fontSize = "pixelsize",
            text,color
        }
    }
    
    
    private enum CodingKeys : String, CodingKey {
        case text
    }
    
    public let text : TextProperties
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if !container.contains(.text) {
            throw ObjectDecodingError.notMyType
        }
        
        text = try container.decode(TextProperties.self, forKey: .text)
        
        try super.init(from: decoder)
    }
}


public class PolygonObject<Engine:GameEngine> : Object<Engine>{
    private enum CodingKeys : String, CodingKey {
        case polygon
    }
    
    public let points : [Position]
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if !container.contains(.polygon) {
            throw ObjectDecodingError.notMyType
        }
        
        points = try container.decode([Position].self, forKey: .polygon)
        
        try super.init(from: decoder)
    }
}

public class PolylineObject<Engine:GameEngine> : Object<Engine>{
    private enum CodingKeys : String, CodingKey {
        case polyline
    }
    
    public let points : [Position]
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if !container.contains(.polyline) {
            throw ObjectDecodingError.notMyType
        }
        
        points = try container.decode([Position].self, forKey: .polyline)
        
        try super.init(from: decoder)
    }
}

extension ObjectLayer {
    func decodeObjects<Engine:GameEngine>(from container: UnkeyedDecodingContainer, in context:DecodingContext<Engine>) throws -> [Object<Engine>] {
        var container = container
        let objectKinds = [PolylineObject<Engine>.self, PolygonObject<Engine>.self, PointObject<Engine>.self, TextObject<Engine>.self, TileObject<Engine>.self, EllipseObject<Engine>.self, RectangleObject<Engine>.self]
        
        var objects = [Object<Engine>]()

        ontoNextObject: while !container.isAtEnd {
            for objectKind in objectKinds {
                do {
                    objects.append(try container.decode(objectKind))
                    
                    continue ontoNextObject
                } catch let error as DecodingError {
                    throw error
                } catch _ as Object<Engine>.ObjectDecodingError {
                    continue
                }
            }

        }
        
        return objects
    }
}

public extension LayerContainer {
    func customObjects<T,E:GameEngine>(for engine:E.Type, traverseGroups:Bool = false)->[T]{
        var objects = [T]()
        
        for layer in getObjectLayers(recursively: traverseGroups) as [ObjectLayer<E>]{
            objects.append(contentsOf: layer.objects.compactMap({$0.type as? T}))
        }
        
        return objects
    }
}
