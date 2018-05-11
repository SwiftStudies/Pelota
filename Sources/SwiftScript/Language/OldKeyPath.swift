//
//  Reference.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

//This is probably what a keypath really is
public typealias KeyPath = [String]

public struct OldKeyPath {
    let object   : String?
    let property : String
    
    var keyPath : KeyPath {
        if let object = object {
            return [object,property]
        }
        return [property]
    }
}
