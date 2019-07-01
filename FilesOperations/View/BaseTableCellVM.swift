//
//  BaseTableCellVM.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation
import AppKit

protocol BaseTableCellViewModelProtocol: class {
    var text: String? { get }
    var image: NSImage? { get }
}

class BaseTableCellVM: BaseTableCellViewModelProtocol {
    let text: String?
    let image: NSImage?
    
    init(text: String?, image: NSImage? = nil) {
        self.text  = text
        self.image = image
    }
}
