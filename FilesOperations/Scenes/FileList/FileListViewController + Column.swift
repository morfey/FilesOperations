//
//  FileListViewController + Column.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation

extension FileListViewController {
    enum Column {
        case name([CellType])
        case size([CellType])
        case date([CellType])
        case md5([CellType])
    }
}
