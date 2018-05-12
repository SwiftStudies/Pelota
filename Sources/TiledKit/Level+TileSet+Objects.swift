//
//  Level+Physics.swift
//  Cascade Brexit Edition
//
//  Created on 06/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

public extension Level {
    public var tileObjectLayers : [Int : ObjectLayer] {
        
        var results = [Int:ObjectLayer]()
        for (gid,tile) in tiles {
            if let objectLayer = tile.objects {
                results[gid] = objectLayer
            }
        }
        
        return results
    }
}
