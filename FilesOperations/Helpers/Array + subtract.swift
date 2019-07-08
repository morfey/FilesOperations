//
//  Array + subtract.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/8/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    func subtract(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.subtracting(otherSet))
    }
}
