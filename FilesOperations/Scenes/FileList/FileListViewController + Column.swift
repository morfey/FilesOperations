//
//  FileListViewController + Column.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation
import AppKit

extension FileListViewController {
    enum Column {
        case name([CellType])
        case size([CellType])
        case date([CellType])
        case md5([CellType])
        
        var identifier: NSUserInterfaceItemIdentifier {
            var str = ""
            switch self {
            case .date:
                str = "dateColumn"
            case .name:
                str = "nameColumn"
            case .size:
                str = "sizeColumn"
            case .md5:
                str = "md5Column"
            }
            return NSUserInterfaceItemIdentifier(str)
        }
        
        var headerTitle: String {
            switch self {
            case .date:
                return "Date Modified"
            case .name:
                return "Name"
            case .size:
                return "Size"
            case .md5:
                return "MD5"
            }
        }
        
        var sortKey: String {
            switch self {
            case .date:
                return "date"
            case .name:
                return "name"
            case .size:
                return "size"
            case .md5:
                return "md5Hex"
            }
        }
        
        var cellIdentifier: NSUserInterfaceItemIdentifier {
            var str = ""
            switch self {
            case .name:
                str = "ImageCell"
            default:
                str = "TextCell"
            }
            return NSUserInterfaceItemIdentifier(str)
        }
    }
}
