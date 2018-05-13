//
//  SpriteKit.swift
//  TiledKit
//
//


#if os(macOS) || os(tvOS) || os(watchOS) || os(iOS)
import SpriteKit
import Pelota

public class SpriteKit : GameEngine {
    public typealias Texture   = SKTexture
    public typealias Container = LayerContainer

    public let physicsCategories = PhysicsCategory()
    public var textureCache      = TextureCache<Texture>()
    
    public required init(){
        
    }
}

public final class PhysicsCategory {
    private var physicsBodyCategories = [String : UInt32]()

    public init(){
        
    }
    
    public func getCategory(`for` name:String)->UInt32{
        if let existingCategory = physicsBodyCategories[name] {
            return existingCategory
        }
        let newCategory : UInt32 = 1 << physicsBodyCategories.count
        physicsBodyCategories[name] = newCategory

        return newCategory
    }
    
    public func getMask(`for` list:[String])->UInt32{
        var mask : UInt32 = 0

        for category in list {
            mask |= getCategory(for: category)
        }

        return mask
    }
}

public extension Position {
    public var cgPoint : CGPoint {
        return CGPoint(x:CGFloat(self.x), y: -CGFloat(self.y))
    }
}


public extension Array where Element == Position {
    public var cgPath : CGPath {
        let path = CGMutablePath()
        
        guard let startPoint = first?.cgPoint else {
            return path
        }
        
        path.move(to: startPoint)
        
        for position in self[1..<count] {
            path.addLine(to: position.cgPoint)
        }
        
        path.closeSubpath()
        
        return path
    }
}

#endif
