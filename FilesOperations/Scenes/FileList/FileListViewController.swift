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
    private(set) var factory: Factory!
    
    private lazy var service = factory.makeFileService()
    private lazy var dataStore = factory.makeDataSource()
    
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
        if !dataStore.files.isEmpty {
            var nameRows: [CellType] = []
            var dateRows: [CellType] = []
            var sizeRows: [CellType] = []
            var md5Rows: [CellType] = []
            dataStore.files.forEach {
                let nameVM = BaseTableCellVM(text: $0.name, image: $0.icon)
                let dateVM = BaseTableCellVM(text: dateFormatter.string(from: $0.date))
                let sizeVM = BaseTableCellVM(text: $0.isDirectory ? "--" : sizeFormatter.string(fromByteCount: $0.size))
                nameRows.append(.baseCell(nameVM))
                dateRows.append(.baseCell(dateVM))
                sizeRows.append(.baseCell(sizeVM))
                md5Rows.append(.baseCell(BaseTableCellVM(text: $0.md5Hex ?? "--")))
            }
            columns.append(.name(nameRows))
            columns.append(.date(dateRows))
            columns.append(.size(sizeRows))
            columns.append(.md5(md5Rows))
        }
        self.columns = columns
        filesTableView.reloadData()
    }
    
    fileprivate func reloadFileList(with order: DataSource.FileOrder, ascending: Bool) {
        dataStore.contentsOrderedBy(order, ascending: ascending)
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
        resetProgressCircle()
        
        service.remove(selectedFiles) { [weak self] item, progress in
            self?.dataStore.remove(item)
            mainQueue { [weak self] in
                self?.progressCircle.animateToDoubleValue(value: progress)
                self?.removeFromTableView(file: item)
            }
        }
    }
    
    @IBAction func md5BtnTapped(_ sender: Any) {
        resetProgressCircle()
        
        service.generateMd5(selectedFiles) { [weak self] item, progress in
            mainQueue { [weak self] in
                guard let `self` = self else { return }
                switch progress {
                case .some(let value):
                    self.progressCircle.animateToDoubleValue(value: value)
                case .done(let hexArray, let errors):
                    self.addHexStrings(hexArray as? [String?] ?? [])
                    self.progressCircle.isHidden = true
                    self.presetErrorsIfNeeded(errors)
                }
            }
        }
    }
    
    fileprivate func removeFromTableView(file: FileMeta) {
        if let index = dataStore.index(of: file) {
            filesTableView.removeRows(at: IndexSet(integer: index), withAnimation: .effectFade)
        }
    }
    
    fileprivate func resetProgressCircle() {
        progressCircle.doubleValue = 0
        progressCircle.isHidden = false
    }
    
    fileprivate func addHexStrings(_ hexArray: [String?]) {
        dataStore.addMD5Hex(hexArray)
        if filesTableView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "MD5Cell")) == nil {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("MD5Cell"))
            column.headerCell.stringValue = "MD5"
            filesTableView.addTableColumn(column)
        }
        reloadData()
    }
    
    fileprivate func presetErrorsIfNeeded(_ errors: [Error?]) {
        let stringErrors = errors.compactMap { $0?.localizedDescription }
        if !stringErrors.isEmpty {
            self.presentAsSheet(self.factory.makeErrorListViewController(errors: stringErrors))
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
        
        let cell: BasicTableCell? = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("SizeCell"), owner: nil) as? BasicTableCell
        cell?.configureCell(vm: factory.vm)
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        selectedFiles = []
        filesTableView.selectedRowIndexes.forEach {
            if let file = dataStore.files[safe: $0] {
                selectedFiles.append(file)
            }
        }
    }
    
    private func rows(inColumn column: Int) -> [CellType] {
        switch columns[safe: column] {
        case .name(let rows)?,
             .size(let rows)?,
             .md5(let rows)?,
             .date(let rows)?:
            return rows
        case .none:
            return []
        }
    }
    
    private func rowType(atColumn colums: Int, row: Int) -> CellType? {
        return rows(inColumn: colums)[safe: row]
    }
}

// MARK: - NSTableViewDataSource
extension FileListViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataStore.files.count
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
