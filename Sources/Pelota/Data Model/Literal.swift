//
//  Property.swift
//

import Foundation

public enum Literal : Equatable, CustomStringConvertible, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByBooleanLiteral, ExpressibleByArrayLiteral{
    
    
    public typealias ArrayLiteralElement = Byte
    public typealias FloatLiteralType = Float
    public typealias IntegerLiteralType = Int
    public typealias StringLiteralType = String
    public typealias BooleanLiteralType = Bool
    
    public init(integerLiteral value: Int) {
        self = .int(value: value)
    }
    
    public init(floatLiteral value: Float) {
        self = .float(value: value)
    }
    
    public init(booleanLiteral value: Bool) {
        self = .bool(value: value)
    }
    
    public init(stringLiteral value: String) {        
        self = .string(value: value)
    }
    
    public init(arrayLiteral elements: Byte...) {
        assert(elements.count == 3 || elements.count == 4, "Array should be in the form [r,g,b] or [r,g,b,a]")
        if elements.count == 3 {
            self = .color(value: Color(r: elements[0], g: elements[1], b: elements[2]))
        } else {
            self = .color(value: Color(r: elements[0], g: elements[1], b: elements[2], a: elements[3]))
        }
    }


    
    public static func == (lhs: Literal, rhs: Literal) -> Bool {
        switch lhs {
        case string(let lhsValue):
            if let rhsValue = String(rhs), lhsValue == rhsValue {
                return true
            }
        case bool(let lhsValue):
            if let rhsValue = Bool(rhs), lhsValue == rhsValue {
                return true
            }
        case int(let lhsValue):
            if let rhsValue = Int(rhs), lhsValue == rhsValue {
                return true
            }
        case float(let lhsValue):
            if let rhsValue = Float(rhs), lhsValue == rhsValue {
                return true
            }
        case file(let lhsValue):
            if let rhsValue = URL(rhs), lhsValue == rhsValue {
                return true
            }
        case color(let lhsValue):
            if case .color(let rhsValue) = rhs {
                return lhsValue == rhsValue
            }
        }
        
        return false
    }
    
    public var description: String {
        switch self {
        case .string(let value):
            return value
        case .file(let value):
            return "\(value)"
        case .bool(let value):
            return "\(value)"
        case .int(let value):
            return "\(value)"
        case .float(let value):
            return "\(value)"
        case .color(let value):
            return "\(value)"
        }
    }
    
    case string(value:String)
    case bool(value:Bool)
    case int(value:Int)
    case float(value:Float)
    case file(value:URL)
    case color(value:Color)
}
