//
//  Runtime.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

protocol Runtime {
    func pop()
    func push(identifier:String, for this:ScriptType?, with symbols:[Symbol])

    func subscribe(to event:String, from entity:String?, if conditions:[String:Term], notifying:Subscriber)
    func publish(event:Event)

    func resolve(symbol name:String?)->ScriptType
    func resolve(keyPath:KeyPath)->ScriptType
    func resolve(term:Term)->ScriptType
    
    func dumpStack()
}

extension Runtime {
    func send(message name:String,_ parameters:[Symbol], to target:KeyPath){
        let targetInstance = require(resolve(keyPath: target), or: "Could not resolve \(target)")
 
        targetInstance.dispatch(message: name, with: parameters)
     }
}


