//
//  Identifier.swift
//  Pelota
//
//

import Foundation

public struct Identifier : Hashable {
    let stringSource      : String?
    let integerSource     : Int?
    
    public let hashValue         : Int
    
}

extension Identifier : ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    
    public init(integerLiteral value: Int) {
        integerSource = value
        stringSource = nil
        hashValue = "\(value)".hashValue
    }
}

extension Identifier : ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        stringSource = value
        integerSource = nil
        hashValue = value.hashValue
    }
}

extension Identifier : CustomStringConvertible{
    public var description : String {
        return stringSource ?? "\(integerSource!)"
    }
}

extension Identifier : Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self.init(stringLiteral: string)
        } else {
            try self.init(integerLiteral: container.decode(Int.self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let string = stringSource {
            try container.encode(string)
        } else {
            try container.encode(integerSource!)
        }
    }
}
