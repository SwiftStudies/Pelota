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
    
    public func createNode<Engine:GameEngine>(for layer:TileLayer<Engine>, with textureCache:TextureCache<SKTexture>)->SKNode{
        let level = layer.level
        
        let pixelWidth = level.width * level.tileWidth
        let pixelHeight = level.height * level.tileHeight
        
        let allTextures = textureCache
        
        let node = SKNode()
        
        node.name = String(level.properties["name"])
        
        for y in 0..<layer.height {
            for x in 0..<layer.width {
                let texture = layer[x,y]
                guard texture != 0 else {
                    continue
                }
                print(level.engine.textureCache.count," keys")
                print(level.engine.textureCache.allGids)
                let spriteNode = SKSpriteNode(texture: (allTextures[texture]))
                spriteNode.position = CGPoint(x:(x*level.tileWidth+layer.offset.x) - pixelWidth >> 1, y:(-y*level.tileHeight-layer.offset.y) + pixelHeight >> 1)
                spriteNode.position.x += spriteNode.size.width / 2
                spriteNode.position.y += (spriteNode.size.height / 2) - CGFloat(level.tileHeight)
                node.addChild(spriteNode)
            }
        }
        
        return node
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
