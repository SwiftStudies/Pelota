//
//  Identifier.swift
//  Pelota
//
//

import Foundation

struct Identifier : Hashable {
    let stringSource      : String?
    let integerSource     : Int?
    
    let hashValue         : Int
    
}

extension Identifier : ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = Int
    
    init(integerLiteral value: Int) {
        integerSource = value
        stringSource = nil
        hashValue = "\(value)".hashValue
    }
}

extension Identifier : ExpressibleByStringLiteral {
    typealias StringLiteralType = String
    
    init(stringLiteral value: String) {
        stringSource = value
        integerSource = nil
        hashValue = value.hashValue
    }
}

extension Identifier : CustomStringConvertible{
    var description : String {
        return stringSource ?? "\(integerSource!)"
    }
}

extension Identifier : Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self.init(stringLiteral: string)
        } else {
            try self.init(integerLiteral: container.decode(Int.self))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let string = stringSource {
            try container.encode(string)
        } else {
            try container.encode(integerSource!)
        }
    }
}
