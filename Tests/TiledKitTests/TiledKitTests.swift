import XCTest
@testable import TiledKit

extension String : TextureType {
    public static func cache(from path: String) -> TextureType {
        return path
    }
    
    public func subTexture(at: (x: Int, y: Int), with dimensions: (width: Int, height: Int)) -> TextureType {
        return "\(self)(x:\(at.x),y:\(at.y),width:\(dimensions.width), height:\(dimensions.height))"
    }
    
    
}

class TestEngine : GameEngine {
    typealias Texture = String
    static var textureCache = TextureCache<String>()

    required init(){
        
    }
    
}

final class TiledKitTests: XCTestCase {
    func testLevelLoad() {
        let level = Level(fromFile: "/Volumes/Personal/SPM/Pelota/Resources/TestData/Dungeon.json", using: [], for: SpriteKit.self)

        
        print(level.properties)
        print("Tiles")
        for tile in level.tiles.keys.sorted() {
            print("\t\(tile) - \(level.tiles[tile]!.texture(for: TestEngine.self))")
        }
    }


    static var allTests = [
        ("testLevelLoad", testLevelLoad),
    ]
}
