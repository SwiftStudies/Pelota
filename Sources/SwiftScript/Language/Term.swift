//
//  Value.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

enum Term : Decodable {
    fileprivate enum CodingKeys : String, CodingKey {
        case literal, reference
    }

    case literal(Literal)
    case reference(OldKeyPath)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let reference = try container.decodeIfPresent(KeyPath.self, forKey: .reference){
            switch reference.count {
            case 1:
                self = .reference(OldKeyPath(object:nil, property: reference[0]))
            case 2:
                self = .reference(OldKeyPath(object:reference[0], property: reference[1]))
            default:
                fatalError("Could not turn reference \(reference) into Reference object")
            }
        } else if let literal = try container.decodeIfPresent(Literal.self, forKey: .literal){
            self = .literal(literal)
        } else {
            self = .literal(.bool(value: false))
        }
    }
    
}

