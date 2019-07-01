//
//  FileListViewController.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 6/29/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Cocoa
import FileService

class FileListViewController: NSViewController {
    @IBOutlet private(set) weak var filesTableView: NSTableView!
    fileprivate var dataStore: DataSource?
    fileprivate let sizeFormatter = ByteCountFormatter()
    private(set) var fileService: FileServiceProtocol?
    private(set) var selectedFiles = [FileMeta]()
    private(set) var sortOrder = DataSource.FileOrder.name
    private(set) var sortAscending = true
    private(set) var columns: [Column] = []
    
    fileprivate lazy var dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let connection = NSXPCConnection(serviceName: "com.timh.FileService")
        connection.remoteObjectInterface = NSXPCInterface(with: FileServiceProtocol.self)
        connection.resume()
        
        fileService = connection.remoteObjectProxyWithErrorHandler { error in
            print("Received error:", error)
        } as? FileServiceProtocol
        
        let descriptorName = NSSortDescriptor(key: DataSource.FileOrder.name.rawValue, ascending: true)
        let descriptorDate = NSSortDescriptor(key: DataSource.FileOrder.date.rawValue, ascending: true)
        let descriptorSize = NSSortDescriptor(key: DataSource.FileOrder.size.rawValue, ascending: true)
        
        filesTableView.tableColumns[0].sortDescriptorPrototype = descriptorName
        filesTableView.tableColumns[1].sortDescriptorPrototype = descriptorDate
        filesTableView.tableColumns[2].sortDescriptorPrototype = descriptorSize
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    fileprivate func reloadData() {
        var columns: [Column] = []
        if dataStore?.files.isEmpty != true {
            var nameRows: [CellType] = []
            var dateRows: [CellType] = []
            var sizeRows: [CellType] = []
            dataStore?.files.forEach {
                let nameVM = BaseTableCellVM(text: $0.name, image: $0.icon)
                let dateVM = BaseTableCellVM(text: dateFormatter.string(from: $0.date))
                let sizeVM = BaseTableCellVM(text: $0.isDirectory ? "--" : sizeFormatter.string(fromByteCount: $0.size))
                nameRows.append(.baseCell(nameVM))
                dateRows.append(.baseCell(dateVM))
                sizeRows.append(.baseCell(sizeVM))
            }
            columns.append(.name(nameRows))
            columns.append(.date(dateRows))
            columns.append(.size(sizeRows))
        }
        self.columns = columns
        filesTableView.reloadData()
    }
    
    fileprivate func reloadFileList() {
        dataStore?.contentsOrderedBy(sortOrder, ascending: sortAscending)
        reloadData()
    }
    
    @IBAction private func addFilesBtnTapped(_ sender: Any) {
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        
        panel.beginSheetModal(for: window) { [weak self] result in
            if result == NSApplication.ModalResponse.OK {
                self?.dataStore = DataSource(urls: panel.urls)
                self?.reloadData()
            }
        }
    }
    
    @IBAction private func removeBtnTapped(_ sender: Any) {
        selectedFiles.forEach { item in
            fileService?.remove(item.url) { [weak self] in
                if let index = self?.dataStore?.files.firstIndex(of: item) {
                    self?.dataStore?.remove(at: index)
                    mainQueue { [weak self] in
                        self?.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - NSTableViewDelegate
extension FileListViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn,
            let columnIndex = tableView.tableColumns.firstIndex(of: column) else { return nil }
        let type = rowType(atColumn: columnIndex, row: row)
        let factory = TableViewCellHelper.factory(for: type)
        
        let cell: BasicTableCell? = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(column.identifier.rawValue), owner: nil) as? BasicTableCell
        cell?.configureCell(vm: factory.vm)
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
    
    private func rows(inColumn column: Int) -> [CellType] {
        switch columns[column] {
        case .name(let rows),
             .size(let rows),
             .date(let rows):
            return rows
        }
    }
    
    private func rowType(atColumn colums: Int, row: Int) -> CellType? {
        return rows(inColumn: colums)[safe: row]
    }
}

// MARK: - NSTableViewDataSource
extension FileListViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataStore?.files.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        
        if let order = DataSource.FileOrder(rawValue: sortDescriptor.key!) {
            sortOrder = order
            sortAscending = sortDescriptor.ascending
            reloadFileList()
        }
    }
}

