//
//  Method.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

public protocol Symbol {
    var name : String {get}
    var type : ScriptType {get}
    var runTime : Runtime? {get}
}

extension Array where Element == Symbol {
    var symbolLookupTable : [String : ScriptType] {
        var results = [String : ScriptType]()
        
        for element in self {
            results[element.name] = element.type
        }
        
        return results
    }
}

public protocol ScriptType {
    
}

public protocol ValueType : ScriptType {
    var value : Literal {get}
}

extension Literal : ValueType {
    public var value : Literal {
        return self
    }
}

extension ScriptType {
    var valueType : ValueType? {
        return self as? ValueType
    }
    
    var dispatchType : DispatchingType? {
        return self as? DispatchingType
    }
    
    var keyedType : KeyedType? {
        return self as? KeyedType
    }
    
    var value : Literal {
        return require(valueType, or: "\(type(of:self)) is not a value type").value
    }
    

}

public protocol Constant : ValueType {
}

public protocol Variable : ValueType {
    var value : Literal {get set}
}

public protocol KeyedType : ScriptType {
    subscript(key key:String)->ScriptType? {get}
}

public typealias Method = ()->Void

public protocol DispatchingType : ScriptType {
    subscript(dispatch dispatch:String)->Method? {get}
}

public protocol ObjectType : KeyedType, DispatchingType {
}

extension Dictionary : KeyedType, ScriptType where Key == String, Value == ScriptType {
    public subscript(key key:String)->ScriptType? {
        return self[key]
    }
}
