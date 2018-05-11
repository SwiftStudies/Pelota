//
//  Event.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

public struct EventMask {
    let desiredName : String
    let desiredSource : String?
    let desiredProperties : [String:Term]?
}

public struct Event : KeyedType{
    let name   : String
    let source : String
    let data   : KeyedType
    let runTime : Runtime
    
    public subscript(key key:String)->ScriptType? {
        switch key {
        case "name":
            return Literal.string(value: name)
        case "source":
            return Literal.string(value: source)
        case "data":
            return data
        default:
            return nil
        }
    }
    
    func matches(mask:EventMask, for object:Subscriber?)->Bool{
        if name != mask.desiredName {
            return false
        }
        if source != mask.desiredSource ?? source {
            return false
        }
        
        guard let desiredProperties = mask.desiredProperties else {
            return true
        }
        
        for (key, term) in desiredProperties {
            guard let property = data[key: key] else {
                return false
            }
            
            if property.value != runTime.resolve(term: term).value {
                return false
            }
        }
        
        return true
    }
    
}
