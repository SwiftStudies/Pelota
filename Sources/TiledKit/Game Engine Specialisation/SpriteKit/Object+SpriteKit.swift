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

}
#endif
