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
        case md5Hash
    }
    
    init() {}
    
    public mutating func update(with urls: [URL]) {
        let diff = urls.subtract(from: self.urls)
        self.urls.append(contentsOf: diff)
        let requiredAttributes: [URLResourceKey] = [.localizedNameKey,
                                                    .effectiveIconKey,
                                                    .contentModificationDateKey,
                                                    .fileSizeKey,
                                                    .isDirectoryKey]

        diff.forEach {
            do {
                let properties = try $0.resourceValues(forKeys: Set(requiredAttributes))
                
                files.append(FileMeta(name: properties.localizedName ?? "",
                                      date: properties.contentModificationDate ?? Date.distantPast,
                                      size: Int64(properties.fileSize ?? 0),
                                      icon: properties.effectiveIcon as? NSImage ?? NSImage(),
                                      isDirectory: properties.isDirectory ?? false,
                                      url: $0,
                                      md5Hash: nil))
            } catch {
                print("Error reading file attributes")
            }
        }
    }
    
    public mutating func remove(at index: Int) {
        files.remove(at: index)
    }
    
    public mutating func remove(_ file: FileMeta) {
        files.removeAll(where: { $0 == file })
    }
    
    public func index(of file: FileMeta) -> Int? {
        return files.firstIndex(of: file)
    }
    
    public mutating func addMD5Hash(_ array: [String?], to selectedFiles: [FileMeta]) {
        selectedFiles.enumerated().forEach {
            if let index = files.firstIndex(of: $0.element), let string = array[$0.offset] {
                files[index].addHash(string: string)
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
        case .md5Hash:
            sortedFiles = files.sorted {
                return itemComparator(lhs: $0.md5Hash ?? "--",
                                      rhs: $1.md5Hash ?? "--",
                                      ascending: ascending)
            }
        }
        files = sortedFiles
    }
    
    // MARK: - Mock
    public mutating func makeTemporaryFiles() -> [URL] {
        var urls = [URL]()
        let directory = FileManager.default.temporaryDirectory
        for i in ["1", "2", "3", "4"] {
            let filename = directory.appendingPathComponent("output\(i).txt")
            if let _ = try? i.write(to: filename, atomically: true, encoding: String.Encoding.utf8) {
                urls.append(filename)
            }
        }
        return urls
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
