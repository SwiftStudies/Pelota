//
//  Properties.swift
//  Cascade Brexit Edition
//
//  Created on 30/04/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

fileprivate enum PropertyJSONKeys : String, CodingKey {
    case types = "propertytypes", values = "properties"
}

fileprivate struct FlexibleCodingKey : CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        return nil
    }
}

protocol Propertied {
    var  properties : [String : Literal] {get set}
}

fileprivate enum PropertyType : String, Decodable {
    case string, bool, int, float, file, color
}

extension Decodable where Self : Propertied {
    func decode(from decoder:Decoder) throws -> [String : Literal] {
        var properties = [String:Literal]()
        let container = try decoder.container(keyedBy: PropertyJSONKeys.self)
        
        //Not all propertied objects will have properties, in which case this would fail
        if let types = try? container.decode([String:PropertyType].self, forKey: PropertyJSONKeys.types){
            let values = try container.nestedContainer(keyedBy: FlexibleCodingKey.self, forKey: .values)
            for type in types {
                switch type.value {
                case .string:
                    properties[type.key] = Literal.string(value: try values.decode(String.self, forKey: FlexibleCodingKey(stringValue: type.key)!))
                case .bool:
                    properties[type.key] = Literal.bool(value: try values.decode(Bool.self, forKey: FlexibleCodingKey(stringValue: type.key)!))
                case .int:
                    properties[type.key] = Literal.int(value: try values.decode(Int.self, forKey: FlexibleCodingKey(stringValue: type.key)!))
                case .float:
                    properties[type.key] = Literal.float(value: try values.decode(Float.self, forKey: FlexibleCodingKey(stringValue: type.key)!))
                case .file:
                    let pathString = try values.decode(String.self, forKey: FlexibleCodingKey(stringValue: type.key)!)
                    properties[type.key] = Literal.file(value: URL(fileURLWithPath: pathString))
                case .color: //#AARRGGBB
                    let stringValue = try values.decode(String.self, forKey: FlexibleCodingKey(stringValue: type.key)!)
                    let color = Color(from: stringValue)
                    properties[type.key] = Literal.color(value: color)
                }
            }
        }
        
        return properties
    }
}
