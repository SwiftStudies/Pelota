//
//  Runtime.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

public protocol Runtime {
    func pop()
    func push(identifier:String, for this:ScriptType?, with symbols:[Symbol])

    func subscribe(to event:String, from entity:String?, if conditions:[String:Term], notifying:Subscriber)
    func publish(event:Event)

    func resolve(symbol name:String?)->ScriptType
    func resolve(keyPath:KeyPath)->ScriptType
    func resolve(term:Term)->ScriptType
    
    func dumpStack()
}

public typealias ExecutionContext = (scopeIdentifer:String, this:ScriptType?, scopedInstances:[Symbol])

fileprivate struct Instance : Symbol {
    let name   : String
    let type   : ScriptType
    var runTime: Runtime?
    
    init(_ name:String, type:ScriptType, runTime:Runtime){
        self.name = name
        self.type = type
        self.runTime = runTime
    }
}

public extension Runtime {
    public func send(message:Message){
        send(message: message.name, symbols(for: message.parameters ?? []), to: message.target)
    }
    
    func symbols(for parameters:[Parameter])->[Symbol]{
        var results = [Symbol]()
        for parameter in parameters {
            results.append(symbol(for: parameter.type, with: parameter.name))
        }
        return results
    }
    
    func symbol(for type:ScriptType, with name:String)->Symbol{
        return Instance(name, type: type, runTime: self)
    }
    
    func dispatch(message:String, to target:ScriptType, with parameters:[Symbol]){
        let dispatcher = require(target as? DispatchingType, or: "\(self) is not dispatching")
        
        push(identifier:"\(type(of:dispatcher)).\(message)", for: target, with: parameters)
        defer {
            pop()
        }
        
        let method : Method = require(dispatcher[dispatch: message],or: "\(self) does not respond to \(message)")
        method()
    }
    
    func send(message name:String,_ parameters:[Symbol], to target:KeyPath){
        let targetInstance = require(resolve(keyPath: target), or: "Could not resolve \(target)")
 
        dispatch(message: name, to:targetInstance, with: parameters)
     }
    
    func execute(compiledScript script:CompiledScript, in context:ExecutionContext?){
        if let context = context {
            push(identifier: context.scopeIdentifer, for: context.this, with: context.scopedInstances)
            defer {
                pop()
            }
        }
        for command in script {
            command.execute(in:self)
        }
        
    }
}


