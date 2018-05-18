//
//  Texture+SKTexture.swift
//  TiledKit
//
//
#if os(macOS) || os(tvOS) || os(watchOS) || os(iOS)
import SpriteKit

extension SKTexture : TextureType {
    public static func cache(from path: String) -> TextureType {
        let url = URL(fileURLWithPath: path)

        if Thread.isMainThread {
            //If we are in an app bundle
            if CommandLine.arguments[0].contains(".app/"){
                let texture = SKTexture(imageNamed: url.lastPathComponent)
                texture.filteringMode = .nearest
                return texture
            } else {
                #if os(macOS)
                    let texture = SKTexture(image: NSImage(contentsOf: url)!)
                    texture.filteringMode = .nearest
                    return texture
                #else
                    fatalError("Image loading outside of Cocoa or an app bundle not supported yet")
                #endif
            }
        }
        print("WARNING: Switching to main thread in order to load a texture. This will be slow if you are loading many textures at the same time")
        var texture : SKTexture!

        DispatchQueue.main.sync {
            texture = SKTexture(imageNamed: url.lastPathComponent)
        }
        print("WARNING: Returning to background thread. This message is intended to annoy you into resolving the issue. ")

        return texture
    }
    
    public func subTexture(at: (x: Int, y: Int), with dimensions: (width: Int, height: Int), from sheet:TileSheet) -> TextureType {
        
        let x :CGFloat = CGFloat(at.x) / CGFloat(sheet.imageWidth)
        var y :CGFloat = CGFloat(at.y) / CGFloat(sheet.imageHeight)
        let width = CGFloat(dimensions.width) / CGFloat(sheet.imageWidth)
        let height = CGFloat(dimensions.height) / CGFloat(sheet.imageHeight)
        y = (1 - height) - y
        
//        let places = 10
//        x = x.floored(toPlaces: places)
//        y = y.floored(toPlaces: places)
//        width = width.ceiled(toPlaces:places)
//        height = height.ceiled(toPlaces: places)

        let rect = CGRect(x: x, y: y, width: width, height: height)
        
        let texture =  SKTexture(rect: rect, in: self)
        texture.filteringMode = .nearest
        return texture
    }
    
}

extension BinaryFloatingPoint {
    public func floored(toPlaces places: Int) -> Self {
        assert(places >= 0)
        let divisor = Self((0..<places).reduce(1.0) { (accum, _) in 10.0 * accum })
        return floor((self * divisor)) / divisor
    }
    public func ceiled(toPlaces places: Int) -> Self {
        assert(places >= 0)
        let divisor = Self((0..<places).reduce(1.0) { (accum, _) in 10.0 * accum })
        return ceil((self * divisor)) / divisor
    }
}


#endif
