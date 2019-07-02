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
    @IBOutlet private weak var progressCircle: NSProgressIndicator!
    @IBOutlet private weak var filesTableView: NSTableView!
    
    private(set) var selectedFiles = [FileMeta]()
    private(set) var columns: [Column] = []
    
    private(set) var factory: Factory?
    private lazy var service = factory?.makeFileService()
    private lazy var dataStore = factory?.makeDataSource()
    
    fileprivate lazy var sizeFormatter = ByteCountFormatter()

    typealias Factory = ViewControllerFactory & FileServiceFactory & DataSouceFactory
    
    fileprivate lazy var dateFormatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
        return dateFormatter
    }()
    
    static func makeFromStoryboard(with factory: Factory) -> FileListViewController {
        let vc = NSStoryboard(name: .main).instantiateVC(withIdentifier: "FilesListVC") as! FileListViewController
        vc.factory = factory
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    fileprivate func reloadFileList(with order: DataSource.FileOrder, ascending: Bool) {
        dataStore?.contentsOrderedBy(order, ascending: ascending)
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
        progressCircle.doubleValue = 0
        progressCircle.isHidden = false
        service?.remove(urls: selectedFiles.map { $0.url }) { [weak self] item, progress in
            if let index = self?.dataStore?.files.firstIndex(where: { $0.url == item }) {
                self?.dataStore?.remove(at: index)
                mainQueue { [weak self] in
                    let _ = self?.progressCircle.animateToDoubleValue(value: progress)
                    self?.filesTableView.removeRows(at: IndexSet(integer: index),
                                                    withAnimation: .effectFade)
                    self?.progressCircle.isHidden = progress > 99
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
        
        if let key = sortDescriptor.key, let order = DataSource.FileOrder(rawValue: key) {
            reloadFileList(with: order, ascending: sortDescriptor.ascending)
        }
    }
}
