//
//  Data+BundleExternalLoading.swift
//  Pelota
//
//

import Foundation

public extension Data {
    public static func withContentsInBundleFirst(url:URL)->Data {
        let data : Data
        
        if let bundleUrl = Bundle.main.url(forResource: url.lastPathComponent.replacingOccurrences(of: ".json", with: ""), withExtension: "json"){
            guard let bundleData = try? Data(contentsOf: bundleUrl) else {
                fatalError("Could not load bundle resource \(url) as data")
            }
            data = bundleData
        } else {
            guard let externalData = try? Data(contentsOf: url) else {
                fatalError("Could not load external \(url) as data")
            }
            data = externalData
        }
        
        return data
    }
}
