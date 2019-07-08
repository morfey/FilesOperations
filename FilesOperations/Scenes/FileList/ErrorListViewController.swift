//
//  ErrorListViewController.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/4/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Cocoa

class ErrorListViewController: NSViewController {
    @IBOutlet private weak var errorListTableView: NSTableView!
    private(set) var errors: [String]
    
    init(errors: [String]) {
        self.errors = errors
        super.init(nibName: NibName.errorsListVC.rawValue, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - NSTableViewDelegate
extension ErrorListViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("cell"),
                                                       owner: nil) as? BasicTableCell
        cell?.textField?.stringValue = errors[safe: row] ?? ""
        return cell
    }
}

// MARK: - NSTableViewDataSource
extension ErrorListViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return errors.count
    }
}
