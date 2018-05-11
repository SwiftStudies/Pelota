//
//  Literal.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

extension Literal : Decodable {
    enum CodingKeys : String, CodingKey {
        case integer, string, boolean, real, color
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let int = try container.decodeIfPresent(Int.self, forKey: .integer) {
            self = .int(value: int)
        } else if let bool = try container.decodeIfPresent(Bool.self, forKey: .boolean){
            self = .bool(value: bool)
        } else if let real = try container.decodeIfPresent(Float.self, forKey: .real){
            self = .float(value: real)
        } else if let color = try container.decodeIfPresent(Color.self, forKey: .color){
            self = .color(value: color)
        } else if let string = try container.decodeIfPresent(String.self, forKey: .string){
            self = .string(value: string[1..<string.count-1])
        } else {
            self = .string(value: "Could not decode")
        }
    }
}
