//
//  LayerContainer.swift
//  Cascade Brexit Edition
//
//  Created on 01/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

public enum LayerType : Decodable {
    case object, group, tile
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        switch try container.decode(String.self, forKey: .type){
        case "objectgroup":
            self = .object
        case "group":
            self = .group
        case "tilelayer":
            self = .tile
        default:
            fatalError("Unknown layer type")
        }
    }
    
    private enum CodingKeys : String, CodingKey {
        case type
    }
}

extension Layer {
    var type : LayerType {
        if self is GroupLayer {
            return .group
        } else if self is TileLayer {
            return .tile
        } else if self is ObjectLayer{
            return .object
        }
        fatalError("Layer of unknown type")
    }
}

public enum LayerContainerReference<Engine:GameEngine> {
    case    level(level:Level<Engine>),
            group(group:GroupLayer<Engine>),
            tile(tile:TileSet<Engine>.Tile)
    
    var group : GroupLayer<Engine>? {
        if case let .group(group) = self {
            return group
        }
        return nil
    }
    
    var level : Level<Engine>? {
        if case let .level(level) = self {
            return level
        }
        return nil
    }
    
    var tile : TileSet<Engine>.Tile? {
        if case let .tile(tile) = self {
            return tile
        }
        return nil
    }
    
    var parent : LayerContainerReference<Engine>{
        switch self {
        case .level:
            return self
        case .tile:
            return self
        case .group(let group):
            return require(group.parent(), or: "This group has no parent")
        }
    }
}

public protocol LayerContainer {
    func parent<Engine:GameEngine>()->LayerContainerReference<Engine>?
    func layers<Engine:GameEngine>()->[Layer<Engine>]
}

//public protocol LayerContainer {
//    associatedtype Engine : GameEngine
////    var parent : Engine.Container {get}
//    var layers : [Layer<Engine>] {get}
//}

extension LayerContainer {
    public func level<Engine:GameEngine>()->Level<Engine>?{
        guard let parentContainer : LayerContainerReference<Engine> = parent() else {
            return nil
        }
        
        switch parentContainer {
        case .level(let level):
            return level
        case .tile:
            return nil
        case .group(let group):
            return group.level
        }
        
    }

    
    public func getGroups<Engine:GameEngine>(named name:String? = nil, matching conditions:[String:Literal] = [:], recursively:Bool = false)->[GroupLayer<Engine>]{
        return getLayers(ofType: .group, named: name, matching: conditions, recursively: recursively) as! [GroupLayer<Engine>]
    }

    public func getObjectLayers<Engine:GameEngine>(named name:String? = nil, matching conditions:[String:Literal] = [:], recursively:Bool = false)->[ObjectLayer<Engine>]{
        return getLayers(ofType: .object, named: name, matching: conditions, recursively: recursively) as! [ObjectLayer<Engine>]
    }

    public func getTileLayers<Engine:GameEngine>(named name:String? = nil, matching conditions:[String:Literal] = [:], recursively:Bool = false)->[TileLayer<Engine>]{
        return getLayers(ofType: .tile, named: name, matching: conditions, recursively: recursively) as! [TileLayer<Engine>]
    }
    
    public func getLayers<Engine:GameEngine>(ofType type:LayerType, named name:String?, matching conditions:[String:Literal], recursively:Bool)->[Layer<Engine>]{
        var matchingLayers = [Layer<Engine>]()
        
        for layer : Layer<Engine> in layers() {
            var matches = true
            if layer.type == type {
                if let name = name, layer.name != name{
                    matches = false
                } else {
                    for (requiredProperty,requiredValue) in conditions {
                        if let layerValue = layer.properties[requiredProperty] {
                            if layerValue != requiredValue {
                                matches = false
                                break
                            }
                        } else {
                            matches = false
                            break
                        }
                    }
                }
            } else {
                matches = false
            }
            
            if matches {
                matchingLayers.append(layer)
            }
            
            // Done depth first to preserve over all top-to-bottom ordering
            if let group = layer as? GroupLayer, recursively {
                matchingLayers.append(contentsOf: group.getLayers(ofType: type, named: name, matching: conditions, recursively: true))
            }
        }
        
        return matchingLayers
    }
    
    static func decodeLayers<E:GameEngine>(_ container:KeyedDecodingContainer<Level<E>.CodingKeys>) throws ->[Layer<E>]  {
        var typeExposer     = try container.nestedUnkeyedContainer(forKey: Level.CodingKeys.layers)
        var undecodedLayers = try container.nestedUnkeyedContainer(forKey: Level.CodingKeys.layers)
        var decodedLayers = [Layer<E>]()
        while !undecodedLayers.isAtEnd {
            let layerType = try typeExposer.decode(LayerType.self)
            switch layerType {
            case .group:
                decodedLayers.append(try undecodedLayers.decode(GroupLayer<E>.self))
            case .object:
                decodedLayers.append(try undecodedLayers.decode(ObjectLayer<E>.self))
            case .tile:
                decodedLayers.append(try undecodedLayers.decode(TileLayer<E>.self))
            }
        }
        return decodedLayers
    }
}
