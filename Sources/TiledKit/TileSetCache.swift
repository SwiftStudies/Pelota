//
//  TileSetCache.swift
//  TiledKit
//
//

import Foundation
import Pelota

fileprivate struct TileSetNameOnly : Decodable {
    let name : String
}

enum TileSetCache {
    static var fileTileSetMap   = [URL : TileSet]()
    static var cache            = [Identifier : TileSet]()
    
    
    static func tileSet(from tileSetReference:TileSetReference)->TileSet{
        if let identifier = tileSetReference.identifier, let cachedSet = cache[identifier] {
            return cachedSet
        }
        
        let identifier : Identifier!
        
        // Always update the identifier to make subseuence look-ups more efficient
        defer {
            tileSetReference.identifier = identifier
        }
        
        //Try finding it in the cache by its URL
        let url = URL(fileURLWithPath: tileSetReference.file)
        if let tileSet = TileSetCache.fileTileSetMap[url] {
            identifier = Identifier(stringLiteral: tileSet.name)
            return tileSet
        }
        
        // Try finding it in the cache by its tileset name which at this point means loading it
        let tileSetName = try! JSONDecoder().decode(TileSetNameOnly.self, from: Data.withContentsInBundleFirst(url:url)).name
        identifier = Identifier(stringLiteral: tileSetName)
        if let cachedWithSameName = cache[Identifier(stringLiteral: tileSetName)] {
            return cachedWithSameName
        }
        
        let newTileSet = TileSet(from: url)
        
        fileTileSetMap[url] = newTileSet
        cache[identifier] = newTileSet
        
        return newTileSet
    }
    
    static func tileSet(named name:String)->TileSet?{
        return cache[Identifier(stringLiteral: name)]
    }
}
