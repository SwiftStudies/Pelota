//
//  Property.swift
//

import Foundation

public enum Literal : Equatable, CustomStringConvertible{
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
