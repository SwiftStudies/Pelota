//
//  ScriptObject.swift
//  Cascade Brexit Edition
//
//  Created on 09/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

protocol Subscriber : Symbol, ScriptType{
    func respond(to event:Event)
}
