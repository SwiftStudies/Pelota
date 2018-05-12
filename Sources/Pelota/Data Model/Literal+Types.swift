//
//  PropertyValues+Types.swift
//  Cascade Brexit Edition
//
//  Created on 01/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

public extension String {
    public init?(_ value:Literal?){
        guard let value = value else {
            return nil
        }
        switch value {
        case .string(let value):
            self = value
        default:
            return nil
        }
    }
}

public extension Int {
    public init?(_ value:Literal?){
        guard let value = value else {
            return nil
        }
        if case Literal.int(let intValue) = value {
            self = intValue
        } else {
            return nil
        }
    }
}

public extension Bool {
    public init?(_ value:Literal?){
        guard let value = value else {
            return nil
        }
        if case Literal.bool(let actualValue) = value {
            self = actualValue
        } else {
            return nil
        }
    }
}

public extension Float {
    public init?(_ value:Literal?){
        guard let value = value else {
            return nil
        }
        if case Literal.float(let actualValue) = value {
            self = actualValue
        } else {
            return nil
        }
    }
}

public extension URL {
    public init?(_ value:Literal?){
        guard let value = value else {
            return nil
        }
        if case Literal.file(let actualValue) = value {
            self = actualValue
        } else {
            return nil
        }
    }
}


