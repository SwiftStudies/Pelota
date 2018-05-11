//
//  Method.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

protocol Symbol {
    var name : String {get}
    var type : ScriptType {get}
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

protocol ScriptType {
    
}

protocol ValueType : ScriptType {
    var value : Literal {get}
}

extension Literal : ValueType {
    var value : Literal {
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
    
    func dispatch(message:String, with parameters:[Symbol]){
        let dispatcher = require(self.dispatchType, or: "\(self) is not dispatching")
        
        runTime?.push(identifier:"\(type(of:dispatcher)).\(message)", for: self, with: parameters)
        defer {
            runTime?.pop()
        }
        
        let method : Method = require(dispatcher[dispatch: message],or: "\(self) does not respond to \(message)")
        method()
    }

}

protocol Constant : ValueType {
}

protocol Variable : ValueType {
    var value : Literal {get set}
}

protocol KeyedType : ScriptType {
    subscript(key key:String)->ScriptType? {get}
}

typealias Method = ()->Void

protocol DispatchingType : ScriptType {
    subscript(dispatch dispatch:String)->Method? {get}
}

protocol ObjectType : KeyedType, DispatchingType {
}

struct Instance : Symbol {
    let name   : String
    let type   : ScriptType
    
    init(_ name:String, type:ScriptType){
        self.name = name
        self.type = type
    }
}

extension Dictionary : KeyedType, ScriptType where Key == String, Value == ScriptType {
    subscript(key key:String)->ScriptType? {
        return self[key]
    }
}
