//
//  SpriteKit.swift
//  TiledKit
//
//


#if os(macOS) || os(tvOS) || os(watchOS) || os(iOS)
import SpriteKit
import Pelota

public struct SpriteKit : GameEngine {
    public typealias Texture   = SKTexture
    public typealias Container = LayerContainer
    
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
