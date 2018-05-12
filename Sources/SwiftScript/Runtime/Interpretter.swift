//
//  Script+AST.swift
//  Cascade Brexit Edition
//
//  Created on 08/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import OysterKit

public enum Interpretter {

    public static func parse(parameters:String?) throws ->[String:Term]{
        guard let parameters = parameters?.replacingOccurrences(of: "=", with: ":") else {
            return [:]
        }
        
        let parser = Parser(grammar: [SwiftScript.parameters._rule()])
        
        // Process their input
        do {
            let parsedParameters = try ParsingDecoder().decode([Parameter].self, from: parameters, using: parser)

            var results = [String:Term]()
            for parameter in parsedParameters {
                results[parameter.identifier] = parameter.term
            }
            return results
        } catch {
            fatalError("Could not parse:\n\n \(parameters)")
        }
    }
    
    public static func compile(source:String)->CompiledScript {
        // Process their input
        do {
            let commands = try ParsingDecoder().decode([Command].self, from: source, using: SwiftScript.generatedLanguage)
            
            return commands
        } catch {
            fatalError("Could not parse:\n\n \(source)")
        }
    }

}


