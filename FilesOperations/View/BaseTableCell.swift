//
//  BaseTableCell.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation
import AppKit

class BasicTableCell: NSTableCellView, TableViewCellProtocol {
    fileprivate weak var viewModel: BaseTableCellVM? { didSet { updateViews() } }
    
    func name() -> String {
        return "BasicTableCell"
    }
    
    static func make() -> TableViewCellProtocol {
        return BasicTableCell()
    }
    
    func configureCell(vm: Any?) {
        if let vm = vm as? BaseTableCellVM {
            configure(viewModel: vm)
        }
    }
    
    func configure(viewModel: BaseTableCellVM) {
        self.viewModel = viewModel
    }
    
    fileprivate func updateViews() {
        guard let viewModel     = viewModel else { return }
        textField?.stringValue  = viewModel.text ?? ""
        imageView?.image        = viewModel.image
    }
}
