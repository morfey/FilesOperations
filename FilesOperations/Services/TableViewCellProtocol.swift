//
//  TableViewCellProtocol.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation
import AppKit

protocol TableViewCellProtocol {
    static func make() -> TableViewCellProtocol
    func name() -> String
    func configureCell(vm: Any?)
}

typealias TableViewCellFactory = () -> TableViewCellProtocol

enum CellType {
    case
    baseCell(BaseTableCellVM)
}

enum TableViewCellHelper {
    static func factory(for type: CellType?) -> (cell: TableViewCellFactory, vm: Any?) {
        switch type {
        case .baseCell(let vm)?:
            return (BasicTableCell.make, vm)
        case .none:
            return (BasicTableCell.make, nil)
        }
    }
}

