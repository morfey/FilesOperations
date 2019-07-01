//
//  Array + safe.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 6/29/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
