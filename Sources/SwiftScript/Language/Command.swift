//
//  Command.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

struct Command : Decodable {
    let sendMessage : Message
    
    func execute(by scriptable:ScriptType? = nil){
        if let scriptable = scriptable {
            runTime?.push(identifier: "\(type(of:scriptable)).executeCommand", for: scriptable, with: [])
            defer {
                runTime?.pop()
            }
        }
        sendMessage.send()
    }
}

typealias CompiledScript = [Command]

extension Array where Element == Command {
    func execute(){
        for command in self {
            command.execute()
        }
    }
}
