//
//  Parameter.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

struct Parameter : Decodable, Symbol {
    let identifier : String
    let term       : Term
    
    var name: String {
        return identifier
    }
    
    var type: ScriptType {
        return require(runTime, or:"No runtime").resolve(term: term)
    }
    

}

