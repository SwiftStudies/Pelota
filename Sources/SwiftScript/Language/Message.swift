//
//  Message.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

public struct Message : Decodable{
    fileprivate enum CodingKeys : String, CodingKey {
        case name = "message", target = "reference", parameters = "parameters"
    }
    
    let name    : String
    let target  : KeyPath
    let parameters : [Parameter]?
    var runTime : Runtime? = nil
}
