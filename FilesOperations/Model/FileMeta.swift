//
//  FileMeta.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 6/29/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation
import AppKit

public struct FileMeta: CustomDebugStringConvertible, Equatable {
    let name: String
    let date: Date
    let size: Int64
    let icon: NSImage
    let isDirectory: Bool
    let url: URL
    var md5Hex: String?
    
    public var debugDescription: String {
        return name + " " + "Folder: \(isDirectory)" + " Size: \(size)"
    }
    
    static public func == (lhs: FileMeta, rhs: FileMeta) -> Bool {
        return (lhs.url == rhs.url)
    }
    
    public mutating func addHex(string: String) {
        self.md5Hex = string
    }
}
