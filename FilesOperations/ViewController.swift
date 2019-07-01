//
//  ViewController.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 6/29/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Cocoa
import FileService

extension ViewController {
    fileprivate enum CellIdentifiers {
        static let nameCell = "NameCell"
        static let dateCell = "DateCell"
        static let sizeCell = "SizeCell"
    }
}

class ViewController: NSViewController {
    @IBOutlet private(set) weak var filesTableView: NSTableView!
    private(set) var fileService: FileServiceProtocol?
    fileprivate var dataStore: DataSource?
    fileprivate let sizeFormatter = ByteCountFormatter()
    private(set) var selectedFiles = [FileMeta]()
    var sortOrder = DataSource.FileOrder.name
    var sortAscending = true
    
    fileprivate lazy var dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
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
    
    func reloadFileList() {
        dataStore?.contentsOrderedBy(sortOrder, ascending: sortAscending)
        filesTableView.reloadData()
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
    
    @IBAction func removeBtnTapped(_ sender: Any) {
        selectedFiles.forEach { item in
            fileService?.remove(url: item.url) {
                if let index = self.dataStore?.files.firstIndex(of: item) {
                    self.dataStore?.remove(at: index)
                    mainQueue { [weak self] in
                        self?.filesTableView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - NSTableViewDelegate
extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""
        
        guard let item = dataStore?.files[safe: row] else { return nil }
        
         if tableColumn == tableView.tableColumns[0] {
            image = item.icon
            text = item.name
            cellIdentifier = CellIdentifiers.nameCell
        } else if tableColumn == tableView.tableColumns[1] {
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

// MARK: - NSTableViewDataSource
extension ViewController: NSTableViewDataSource {
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

