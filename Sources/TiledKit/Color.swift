//
//  Color.swift
//  Cascade Brexit Edition
//
//  Created on 01/05/2018.
//  Copyright © 2018 RED When Excited Ltd. All rights reserved.
//

import Foundation

public struct Color : Decodable, Equatable{
    let red:Byte, green:Byte, blue:Byte, alpha:Byte
    
    //Tiled represents colors in the form of a string #AARRGGBB
    init(from string:String){
        if string.count == 7 {
            alpha = 255
            red   = Byte(string[1..<3], radix: 16) ?? 255
            green = Byte(string[3..<5], radix: 16) ?? 0
            blue  = Byte(string[5..<7], radix: 16) ?? 255

        } else {
            alpha = Byte(string[1..<3], radix: 16) ?? 255
            red   = Byte(string[3..<5], radix: 16) ?? 255
            green = Byte(string[5..<7], radix: 16) ?? 0
            blue  = Byte(string[7..<9], radix: 16) ?? 255
        }
    }
    
    public init(from decoder:Decoder) throws {
        let stringValue = try decoder.singleValueContainer().decode(String.self)
        let colorObject = Color(from: stringValue)
        red = colorObject.red
        green = colorObject.green
        blue = colorObject.blue
        alpha = colorObject.alpha
    }
}
