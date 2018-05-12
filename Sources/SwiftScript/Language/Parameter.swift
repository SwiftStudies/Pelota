//
//  Parameter.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

public struct Parameter : Decodable, Symbol {
    public var runTime: Runtime? = nil
    
    let identifier : String
    let term       : Term
    
    private enum CodingKeys: String, CodingKey {
        case identifier
        case term
    }
    
    public var name: String {
        return identifier
    }

    public var type: ScriptType{
        return require(runTime, or:"No runtime").resolve(term: term)
    }
    
}

