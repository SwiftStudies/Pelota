//
//  Message.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

struct Message : Decodable{
    fileprivate enum CodingKeys : String, CodingKey {
        case name = "message", target = "reference", _parameters = "parameters"
    }
    
    let name    : String
    let target  : KeyPath
    let _parameters : [Parameter]?
    
    func send(in runTime:Runtime){
        runTime.send(message: name, parameters, to: target)
    }
    
    var parameters : [Symbol]{
        
        return (_parameters ?? []).map({$0.type.instance(identifier: $0.name)})
    }
}
