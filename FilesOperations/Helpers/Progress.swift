//
//  Progress.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/4/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation

enum Progress {
    case some(Double)
    case done([Any?], [Error?])
}
