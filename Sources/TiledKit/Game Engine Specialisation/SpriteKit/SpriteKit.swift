//
//  SpriteKit.swift
//  TiledKit
//
//


#if os(macOS) || os(tvOS) || os(watchOS) || os(iOS)
import SpriteKit
import Pelota

// This is horrible. Needs a better solution
fileprivate var spriteKitInstance : SpriteKit? = nil

public class SpriteKit : GameEngine {
    
    public typealias Texture   = SKTexture

    let physicsCategories = PhysicsCategory()
    public static var textureCache = TextureCache<SKTexture>()

    public required init(){
        spriteKitInstance = self
    }
    
    public init(for level:Level){
        spriteKitInstance = self
        
        for layer in level.getObjectLayers(recursively: true){
            
            for categories in layer.objects.compactMap({String($0.properties["category"])}){
                for category in categories.split(separator: ",").map({$0.trimmingCharacters(in: CharacterSet.whitespaces)}){
                    spriteKitInstance?.physicsCategories.getCategory(for: category)
                }
            }
        }
        
        print("Done!")
    }
    
    public static var instance : SpriteKit? {
        return spriteKitInstance
    }
    
    public static func createNode(for layer:TileLayer, with textureCache:TextureCache<SKTexture>)->SKNode{
        let level = layer.level
        
        let pixelWidth = level.width * level.tileWidth
        let pixelHeight = level.height * level.tileHeight
        
        let node = SKNode()
        
        node.name = String(level.properties["name"])
        
        for y in 0..<layer.height {
            for x in 0..<layer.width {
                let textureGid = layer[x,y]
                guard textureGid != 0 else {
                    continue
                }
                let texture = textureCache[level.tiles[textureGid]!.identifier]

                let spriteNode = SKSpriteNode(texture: texture)
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
    
    @discardableResult
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
