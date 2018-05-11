//
//  Scope.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

// Convert an array of symbols into a symbol table
fileprivate extension Array where Element == Symbol {
    var literalSymbolTable : [String:Literal] {
        var mapped = [String:Literal]()
        for parameter in self {
            mapped[parameter.name] = require(parameter as? ValueType, or: "Cannot resolve value of \(parameter.name)").value
        }
        return mapped
    }
    
    var symbolTable : [String:ScriptType]{
        var mapped = [String:ScriptType]()
        for parameter in self {
            mapped[parameter.name] = parameter.type
        }
        return mapped

    }
}


final class Scope : CustomStringConvertible{
    private var name        : String
    private var parent      : Scope?
    private var symbolTable = [String : ScriptType]()
    private var this        : ScriptType?
    
    init(_ identifier:String, in scope:Scope?, for this:ScriptType?, with symbols:[Symbol]){
        self.name = identifier
        self.parent = scope
        self.this = this
        self.symbolTable = symbols.symbolTable
        self.symbolTable["self"] = this
    }
    
    func resolve(symbol name:String?)->ScriptType?{
        guard let name = name else {
            return this
        }
        
        //This should really call "lookup" to look up in the symbol table and trickle down
        if let type = symbolTable[name] {
            return type
        }
        
        return parent?.resolve(symbol:name)
    }
    
    var description: String {
        let symbols = symbolTable.reduce("") { (previous, next) -> String in
            return "\(previous)\(previous.count == 0 ? "\t" : "\n\t")\(next.key)=\(next.value)"
        }
        return "\(name):\n\(symbols.count == 0 ? "\tEmpty" : symbols)"
    }
}
