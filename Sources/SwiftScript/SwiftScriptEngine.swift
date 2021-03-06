//
//  SSSRuntime.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

public class SwiftScriptEngine : Runtime {
    fileprivate var stack           = [Scope]()
    fileprivate let debuggingMode   = false

    public init(with symbols:[Symbol]){
        push(identifier:"\(type(of:self))", for: nil, with: symbols)
    }
    
    public func resolve(symbol name: String?) -> ScriptType {
        return require(stack.last?.resolve(symbol: name), or: "\(name == nil ? "self" : name!) cannot be resolved")
    }
    
    public func resolve(term:Term)->ScriptType{
        switch term {
        case .literal(let literal):
            return literal
        case .reference(let reference):
            if let symbol = reference.object {
                let keyedSymbol = require(resolve(symbol: symbol) as? KeyedType, or: "\(symbol) does not have properties")
                let propertySymbol = require(keyedSymbol[key: reference.property], or: "\(symbol) does not have property \(reference.property)")
                return propertySymbol
            } else {
                return require(resolve(symbol: reference.property), or: "\(reference.property) does not exist in \(stack)")
            }
            
        }
    }
    
    public func pop() {
        stack.removeLast()
    }
    
    public func push(identifier: String, for this: ScriptType?, with symbols: [Symbol]) {
        stack.append(Scope(identifier, in: stack.last, for: this, with: symbols))
    }
    
    struct Subscription {
        let `for` : Subscriber
        let mask : EventMask
    }
    
    public func subscribe(to event: String, from entity: String?, if conditions: [String : Term], notifying: Subscriber) {
        let mask = EventMask(name: event, from: entity, matching: conditions)
        let subscription = Subscription(for: notifying, mask: mask)
        subscriptions.append(subscription)
    }
    
    public func resolve(keyPath: KeyPath) -> ScriptType {
        guard keyPath.count > 0 else {
            return require(stack.last?.resolve(symbol: nil), or: "self not available")
        }
        var processedKeyPath = keyPath
        let currentKey = processedKeyPath.removeFirst()
        var resolvedObject = require(stack.last?.resolve(symbol: currentKey), or: "\(currentKey) does not exist in scope")
        
        while processedKeyPath.count > 0 {
            let nextKey = processedKeyPath.removeFirst()
            let keyedObject = require(resolvedObject as? KeyedType, or: "\(type(of:resolvedObject)) is not a keyed type")
            resolvedObject = require(keyedObject[key: nextKey], or:"\(type(of:resolvedObject)) does not have a property \(nextKey)")
        }
        return resolvedObject
    }
    
    var subscriptions = [Subscription]()

    func debug(_ message:String){
        if !debuggingMode {
            return
        }
        print(message)
    }
    
    
    
    public func publish(event name:String, from:String, data:KeyedType){
        let event = Event(name: name, source: from, data: data, runTime: self)
        debug("PUBLISH \(event.source)->\(event.name)(\(event.data))")
        for subscription in subscriptions {
            if event.matches(mask: subscription.mask, for: subscription.for){
                debug("        \t->\(subscription.for.name)")
                subscription.for.respond(to:event)
            }
        }
    }
    
    public func dumpStack() {
        print("Stack Dump")
        print(String(repeating: "=", count: 80))
        for scope in stack.lazy.reversed() {
            print(scope.description)
            print(String(repeating: "=", count: 80))
        }
    }
    
}
