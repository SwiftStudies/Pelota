//
//  Object+Physics.swift
//  Cascade Brexit Edition
//
//  Created on 01/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//
#if os(macOS) || os(tvOS) || os(watchOS) || os(iOS)
import SpriteKit
import Pelota

public extension Float {
    var cgFloat : CGFloat {
        return CGFloat(self)
    }
}

public extension Object {
    public var frame : CGRect {
        if let object = self as? EllipseObject {
            return CGRect(x: CGFloat(object.x + (object.width / 2)), y: CGFloat(object.y + object.height / 2), width: CGFloat(object.width), height: CGFloat(object.height))
        } else if let object = self as? RectangleObject {
            return CGRect(x: CGFloat(object.x + (object.width / 2)), y: CGFloat(object.y + (object.height / 2)), width: CGFloat(object.width), height: CGFloat(object.height))
        } else if let object = self as? PolygonObject {
            let size = object.points.cgPath.boundingBox
            return CGRect(x: CGFloat(object.x), y: CGFloat(object.y), width: size.width, height: size.height)
        } else {
            return CGRect(x: CGFloat(x), y: CGFloat(y), width: 4, height: 4)
        }
    }
    public func physicsBody(offsetBy offset:CGPoint = CGPoint.zero, tileTexture:SKTexture? = nil) ->SKPhysicsBody {
        var body : SKPhysicsBody? = nil
        if let object = self as? EllipseObject {
            if object.width == object.height {
                body = SKPhysicsBody(circleOfRadius: CGFloat(object.width / 2))
            } else {
                let path = CGPath(ellipseIn: CGRect(x: object.width.cgFloat / -2, y: object.height.cgFloat / -2, width: object.width.cgFloat, height: object.height.cgFloat), transform: nil)
                body = SKPhysicsBody(polygonFrom: path)
            }
        } else if let object = self as? PolygonObject {
            body = SKPhysicsBody(polygonFrom: object.points.cgPath)
        } else if let object = self as? PolylineObject {
            body = SKPhysicsBody(edgeChainFrom: object.points.cgPath)
        } else if let object = self as? TileObject,let collisionDefinition = object.tile?.objects?.objects.first, let tileTexture = tileTexture  {
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
            return collisionDefinition.physicsBody(offsetBy: offset, tileTexture: tileTexture)
        } else if let object = self as? RectangleObject {
            let size = CGSize(width: Int(object.width), height: Int(object.height))
            body = SKPhysicsBody(rectangleOf: size, center: offset)
        }

        return require(body, or: "No body was created")
    }
    
}
#endif
