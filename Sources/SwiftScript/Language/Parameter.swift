//
//  Parameter.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

public struct Parameter : Decodable {
    let identifier : String
    let term       : Term
    
    private enum CodingKeys: String, CodingKey {
        case identifier
        case term
    }
    
    public var name: String {
        return identifier
    }

    public func resolve(in runtime:Runtime)->ScriptType {
        return runtime.resolve(term: term)
    }
}

