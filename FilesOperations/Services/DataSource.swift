//
//  DataSource.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 6/29/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation
import AppKit

public struct DataSource  {
    private(set) var files: [FileMeta] = []
    private(set) var urls = [URL]()
    
    public enum FileOrder: String {
        case name
        case date
        case size
        case md5Hex
    }
    
    init() {}
    
    public init(urls: [URL]) {
        self.urls = urls
        let requiredAttributes: [URLResourceKey] = [.localizedNameKey,
                                                    .effectiveIconKey,
                                                    .contentModificationDateKey,
                                                    .fileSizeKey,
                                                    .isDirectoryKey]

        urls.forEach {
            do {
                let properties = try $0.resourceValues(forKeys: Set(requiredAttributes))
                
                files.append(FileMeta(name: properties.localizedName ?? "",
                                      date: properties.contentModificationDate ?? Date.distantPast,
                                      size: Int64(properties.fileSize ?? 0),
                                      icon: properties.effectiveIcon as? NSImage  ?? NSImage(),
                                      isDirectory: properties.isDirectory ?? false,
                                      url: $0,
                                      md5Hex: nil))
            }
            catch {
                print("Error reading file attributes")
            }
        }
    }
    
    mutating func remove(at index: Int) {
        files.remove(at: index)
    }
    
    mutating func remove(_ file: FileMeta) {
        files.removeAll(where: { $0 == file })
    }
    
    func index(of file: FileMeta) -> Int? {
        return files.firstIndex(of: file)
    }
    
    mutating func addMD5Hex(_ array: [String?]) {
        array.enumerated().forEach {
            if let string = $0.element {
                files[$0.offset].addHex(string: string)
            }
        }
    } 
    
    mutating func contentsOrderedBy(_ orderedBy: FileOrder, ascending: Bool) {
        let sortedFiles: [FileMeta]
        switch orderedBy {
        case .name:
            sortedFiles = files.sorted {
                return itemComparator(lhs: $0.name.lowercased(),
                                      rhs: $1.name.lowercased(),
                                      ascending: ascending)
            }
        case .size:
            sortedFiles = files.sorted {
                return itemComparator(lhs: $0.size,
                                      rhs: $1.size,
                                      ascending: ascending)
            }
        case .date:
            sortedFiles = files.sorted {
                return itemComparator(lhs: $0.date,
                                      rhs: $1.date,
                                      ascending: ascending)
            }
        case .md5Hex:
            sortedFiles = files.sorted {
                return itemComparator(lhs: $0.md5Hex ?? "--",
                                      rhs: $1.md5Hex ?? "--",
                                      ascending: ascending)
            }
        }
        files = sortedFiles
    }
}

func itemComparator<T: Comparable>(lhs: T, rhs: T, ascending: Bool) -> Bool {
    return ascending ? (lhs < rhs) : (lhs > rhs)
}

public func ==(lhs: Date, rhs: Date) -> Bool {
    if lhs.compare(rhs) == .orderedSame {
        return true
    }
    return false
}

public func <(lhs: Date, rhs: Date) -> Bool {
    if lhs.compare(rhs) == .orderedAscending {
        return true
    }
    return false
}
