//
//  SKPhysicsBody+Tiled.swift
//  TiledKit
//
//

import SpriteKit
import Pelota

public extension SKPhysicsBody{
    
    static func physicsBody(for object:Object, offsetBy offset:CGPoint = CGPoint.zero, tileTexture:SKTexture? = nil)->SKPhysicsBody? {
        var body : SKPhysicsBody? = nil
        if let object = object as? EllipseObject {
            if object.width == object.height {
                body = SKPhysicsBody(circleOfRadius: CGFloat(object.width / 2))
            } else {
                let path = CGPath(ellipseIn: CGRect(x: object.width.cgFloat / -2, y: object.height.cgFloat / -2, width: object.width.cgFloat, height: object.height.cgFloat), transform: nil)
                body = SKPhysicsBody(polygonFrom: path)
            }
        } else if let object = object as? PolygonObject {
            body = SKPhysicsBody(polygonFrom: object.points.cgPath)
        } else if let object = object as? PolylineObject {
            body = SKPhysicsBody(edgeChainFrom: object.points.cgPath)
        } else if let object = object as? TileObject,let collisionDefinition = object.tile?.objects?.objects.first, let tileTexture = tileTexture  {
            //For any other object we use a node to move the physics body to the correct location, within a tile sprite
            //the body needs to be moved for those that are created in the absence of a co-ordinate system (i.e. typically just width and height
            //then shifted by a center
            var collisionObjectOffset = CGPoint.zero
            if let collisionDefinition = collisionDefinition as? RectangleObject {
                //I really don't like that I'm treating the height differently but it was always off by exactly half :/
                collisionObjectOffset = CGPoint(x: CGFloat(collisionDefinition.width) / 2, y: CGFloat(collisionDefinition.height) / 1)
            } else {
                fatalError("Tile based collision objects do not yet support \(collisionDefinition) objects")
            }
            let offset = CGPoint(x: (tileTexture.size().width / -2) + collisionObjectOffset.x, y: tileTexture.size().height / -2 + collisionObjectOffset.y)
            return SKPhysicsBody.physicsBody(for: collisionDefinition,offsetBy: offset, tileTexture: tileTexture)
        } else if let object = object as? RectangleObject {
            let size = CGSize(width: Int(object.width), height: Int(object.height))
            body = SKPhysicsBody(rectangleOf: size, center: offset)
        }
        
        return body
    }
    
    public static func create(from object:Object, defaultCategory category:String?=nil)->SKPhysicsBody?{
        if let physicsCategory = String(object["category"]) ?? category{
            let physicsBody = SKPhysicsBody.physicsBody(for: object)
            physicsBody?.categoryBitMask = SpriteKit.instance?.physicsCategories.getMask(for: physicsCategory.split(separator: ",").map({String($0)})) ?? 0
            if let collisionCategory = String(object.properties["collides"]){
                physicsBody?.collisionBitMask = SpriteKit.instance?.physicsCategories.getMask(for: collisionCategory.split(separator: ",").map({String($0)})) ?? 0
            }
            if let contactCategory = String(object.properties["contacts"]){
                physicsBody?.contactTestBitMask = SpriteKit.instance?.physicsCategories.getMask(for: contactCategory.split(separator: ",").map({String($0)})) ?? 0
            }

            physicsBody?.allowsRotation    = Bool(object.properties["allowsRotation"]) ?? true
            physicsBody?.affectedByGravity = Bool(object.properties["affectedByGravity"]) ?? true
            physicsBody?.isDynamic         = Bool(object.properties["dynamic"]) ?? true


            return physicsBody
        }
        
        
        return nil
    }
}
