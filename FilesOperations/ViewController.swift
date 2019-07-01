//
//  ViewController.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 6/29/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Cocoa

extension ViewController {
    fileprivate enum CellIdentifiers {
        static let selectCell = "SelectCell"
        static let nameCell = "NameCell"
        static let dateCell = "DateCell"
        static let sizeCell = "SizeCell"
    }
}

class ViewController: NSViewController {
    @IBOutlet private(set) weak var filesTableView: NSTableView!
    fileprivate var dataStore: DataSource?
    fileprivate let sizeFormatter = ByteCountFormatter()
    private(set) var selectedFiles = [FileMeta]()
    
    fileprivate lazy var dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func addFilesBtnTapped(_ sender: Any) {
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        
        panel.beginSheetModal(for: window) { [weak self] result in
            if result == NSApplication.ModalResponse.OK {
                self?.dataStore = DataSource(urls: panel.urls)
                self?.filesTableView.reloadData()
            }
        }
    }
}

extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = dataStore?.files[safe: row] else { return nil }
        
        if tableColumn == tableView.tableColumns[0] {
            cellIdentifier = CellIdentifiers.selectCell
        } else if tableColumn == tableView.tableColumns[1] {
            image = item.icon
            text = item.name
            cellIdentifier = CellIdentifiers.nameCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = dateFormatter.string(from: item.date)
            cellIdentifier = CellIdentifiers.dateCell
        } else {
            text = item.isDirectory ? "--" : sizeFormatter.string(fromByteCount: item.size)
            cellIdentifier = CellIdentifiers.sizeCell
        }
        
        guard
            let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier),
                                          owner: nil) as? NSTableCellView
        else { return nil }
        
        cell.textField?.stringValue = text
        cell.imageView?.image = image
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedFiles = []
        filesTableView.selectedRowIndexes.forEach {
            if let file = dataStore?.files[safe: $0] {
                selectedFiles.append(file)
            }
        }
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataStore?.files.count ?? 0
    }
}

