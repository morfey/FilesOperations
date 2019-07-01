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
    }
    
    init() {}
    
    public init(urls: [URL]) {
        self.urls = urls
        let requiredAttributes: [URLResourceKey] = [.localizedNameKey,.effectiveIconKey, .typeIdentifierKey,
                                                    .contentModificationDateKey, .fileSizeKey, .isDirectoryKey,
                                                    .isPackageKey]

        urls.forEach {
            do {
                let properties = try $0.resourceValues(forKeys: Set(requiredAttributes))
                
                files.append(FileMeta(name: properties.localizedName ?? "",
                                      date: properties.contentModificationDate ?? Date.distantPast,
                                      size: Int64(properties.fileSize ?? 0),
                                      icon: properties.effectiveIcon as? NSImage  ?? NSImage(),
                                      isDirectory: properties.isDirectory ?? false,
                                      url: $0))
            }
            catch {
                print("Error reading file attributes")
            }
        }
    }
    
    mutating func remove(at index: Int) {
        files.remove(at: index)
    }
    
    mutating func contentsOrderedBy(_ orderedBy: FileOrder, ascending: Bool) {
        let sortedFiles: [FileMeta]
        switch orderedBy {
        case .name:
            sortedFiles = files.sorted {
                return sortMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending: ascending,
                                    attributeComparation:itemComparator(lhs:$0.name, rhs: $1.name, ascending:ascending))
            }
        case .size:
            sortedFiles = files.sorted {
                return sortMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending:ascending,
                                    attributeComparation:itemComparator(lhs:$0.size, rhs: $1.size, ascending: ascending))
            }
        case .date:
            sortedFiles = files.sorted {
                return sortMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending:ascending,
                                    attributeComparation:itemComparator(lhs:$0.date, rhs: $1.date, ascending:ascending))
            }
        }
        files = sortedFiles
    }
}

func sortMetadata(lhsIsFolder: Bool,
                  rhsIsFolder: Bool,
                  ascending: Bool,
                  attributeComparation: Bool) -> Bool {
    if lhsIsFolder && !rhsIsFolder {
        return ascending ? true : false
    }
    else if !lhsIsFolder && rhsIsFolder {
        return ascending ? false : true
    }
    return attributeComparation
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
