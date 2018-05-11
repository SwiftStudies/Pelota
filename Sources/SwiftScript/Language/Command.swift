//
//  Command.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation
import Pelota

public struct Command : Decodable {
    let sendMessage : Message
    
    func execute(in runTime:Runtime){
        sendMessage.send(in:runTime)
    }
}

public typealias CompiledScript = [Command]
