//
//  Object.swift
//  Cascade Brexit Edition
//
//  Created on 30/04/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

public func require<T>(_ optional:T?,or message:String)->T{
    if let unwrapped = optional {
        return unwrapped
    }
    guruMeditation(message)
}

public protocol CustomObject {
    static var identifier : String { get }
    init?(for object: Object, withLoader levelLoader: LevelLoader?)
}

fileprivate var registeredCustomObjectTypes = [CustomObject.Type]()

enum CustomObjectFactory {
    static func make(for object:Object, with customObjectTypes:[CustomObject.Type], andLoader levelLoader:LevelLoader?)->CustomObject? {
        for type in customObjectTypes {
            if type.identifier == object.rawType ?? "" {
                return type.init(for: object, withLoader: levelLoader)
            }
        }
        return nil
    }
}

public class Object : Decodable, Propertied{
    internal enum ObjectDecodingError : Error {
        case notMyType      // A specialisation cannot decode
        case unknownType    // No specialisation can decode
    }
    private enum CodingKeys : String, CodingKey {
        case id, name, visible, x, y, type
    }
    
    let id          : Int
    let name        : String?
    var type        : CustomObject?
    fileprivate let rawType : String?
    let visible     : Bool
    let x           : Float
    let y           : Float
    let parent      : ObjectLayer
    
    var properties  = [String:Literal]()
    
    var level       : Level {
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
        
        parent = decoder.userInfo.levelDecodingContext.layerPath.last! as! ObjectLayer
        
        // Properties
        properties = try decode(from: decoder)
    }
}

class PointObject : Object {
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

class RectangleObject : Object {
    private enum CodingKeys : String, CodingKey {
        case width, height, rotation
    }

    let width       : Float
    let height      : Float
    let rotation    : Float
    
    required init(from decoder: Decoder) throws {
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

class EllipseObject : RectangleObject {
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

class TileObject : RectangleObject {
    private enum CodingKeys : String, CodingKey {
        case gid, tile
    }
    
    let gid : Int
    var tile    : TileSet.Tile? = nil
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if !container.contains(.gid) {
            throw ObjectDecodingError.notMyType
        }
        
        gid = try container.decode(Int.self, forKey: .gid)
        
        try super.init(from: decoder)
    }
}

class TextObject : RectangleObject {
    struct TextProperties : Decodable{
        let fontName : String
        let fontSize : Int
        let text     : String
        let color    : Color
        
        enum CodingKeys : String, CodingKey {
            case    fontName = "fontfamily",
            fontSize = "pixelsize",
            text,color
        }
    }
    
    
    private enum CodingKeys : String, CodingKey {
        case text
    }
    
    let text : TextProperties
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if !container.contains(.text) {
            throw ObjectDecodingError.notMyType
        }
        
        text = try container.decode(TextProperties.self, forKey: .text)
        
        try super.init(from: decoder)
    }
}

public struct Position : Decodable{
    let x : Float
    let y : Float
}

class PolygonObject : Object {
    private enum CodingKeys : String, CodingKey {
        case polygon
    }
    
    let points : [Position]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if !container.contains(.polygon) {
            throw ObjectDecodingError.notMyType
        }
        
        points = try container.decode([Position].self, forKey: .polygon)
        
        try super.init(from: decoder)
    }
}

class PolylineObject : Object {
    private enum CodingKeys : String, CodingKey {
        case polyline
    }
    
    let points : [Position]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if !container.contains(.polyline) {
            throw ObjectDecodingError.notMyType
        }
        
        points = try container.decode([Position].self, forKey: .polyline)
        
        try super.init(from: decoder)
    }
}

extension ObjectLayer {
    func decodeObjects(from container: UnkeyedDecodingContainer, in context:Level.DecodingContext) throws -> [Object] {
        var container = container
        let objectKinds = [PolylineObject.self, PolygonObject.self, PointObject.self, TextObject.self, TileObject.self, EllipseObject.self, RectangleObject.self]
        
        var objects = [Object]()

        ontoNextObject: while !container.isAtEnd {
            for objectKind in objectKinds {
                do {
                    objects.append(try container.decode(objectKind))
                    
                    continue ontoNextObject
                } catch let error as DecodingError {
                    throw error
                } catch _ as Object.ObjectDecodingError {
                    continue
                }
            }

        }
        
        return objects
    }
}

public extension LayerContainer {
    func customObjects<T>(traverseGroups:Bool = false)->[T]{
        var objects = [T]()
        
        for layer in getObjectLayers(recursively: traverseGroups) {
            objects.append(contentsOf: layer.objects.compactMap({$0.type as? T}))
        }
        
        return objects
    }
}
