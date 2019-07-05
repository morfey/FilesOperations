//
//  FileListViewController.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 6/29/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Cocoa

class FileListViewController: NSViewController {
    @IBOutlet weak var operationPopButton: NSPopUpButton!
    @IBOutlet private weak var runBtn: NSButton!
    @IBOutlet private weak var filesTableView: NSTableView!
    @IBOutlet private weak var progressCircle: NSProgressIndicator!
    
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
    
    init(factory: Factory) {
        self.factory = factory
        super.init(nibName: NibName.filesListVC.rawValue, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        operationPopButton.removeAllItems()
        operationPopButton.addItem(withTitle: "Remove")
        operationPopButton.addItem(withTitle: "MD5")
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    fileprivate func reloadData() {
        selectedFiles = []
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
                let hexVM = BaseTableCellVM(text: $0.md5Hex ?? "--")
                nameRows.append(.baseCell(nameVM))
                dateRows.append(.baseCell(dateVM))
                sizeRows.append(.baseCell(sizeVM))
                md5Rows.append(.baseCell(hexVM))
            }
            columns.append(.name(nameRows))
            columns.append(.date(dateRows))
            columns.append(.size(sizeRows))
            columns.append(.md5(md5Rows))
        }
        self.columns = columns
        filesTableView.reloadData()
        operationBtnsAvailability()
    }
    
    fileprivate func reloadFileList(with order: DataSource.FileOrder, ascending: Bool) {
        dataStore.contentsOrderedBy(order, ascending: ascending)
        reloadData()
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
    
    fileprivate func add(newColumn: Column) {
        if filesTableView.tableColumn(withIdentifier: newColumn.identifier) == nil {
            let column = NSTableColumn(identifier: newColumn.identifier)
            column.headerCell.stringValue = newColumn.headerTitle
            column.sortDescriptorPrototype = NSSortDescriptor(key: newColumn.sortKey, ascending: true)
            filesTableView.addTableColumn(column)
        }
    }
    
    fileprivate func addHexStrings(_ hexArray: [String?]) {
        dataStore.addMD5Hex(hexArray, to: selectedFiles)
        add(newColumn: .md5([]))
        reloadData()
    }
    
    fileprivate func presentErrorsIfNeeded(_ errors: [Error?]) {
        let stringErrors = errors.compactMap { $0?.localizedDescription }
        if !stringErrors.isEmpty {
            self.presentAsSheet(self.factory.makeErrorListViewController(errors: stringErrors))
        }
    }
    
    fileprivate func operationBtnsAvailability() {
        runBtn.isEnabled = !selectedFiles.isEmpty
    }
    
    // MARK: - Actions
    @IBAction private func addFilesBtnTapped(_ sender: Any) {
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        
        panel.beginSheetModal(for: window) { [weak self] result in
            if result == NSApplication.ModalResponse.OK {
                self?.dataStore.update(with: panel.urls)
                self?.reloadData()
            }
        }
    }
    
    @IBAction private func runBtnTapped(_ sender: Any) {
        resetProgressCircle()
        
        service.runSelectedOperation(for: selectedFiles) { [weak self] operation, item, progress in
            switch operation {
            case .md5:
                self?.handleMD5Progress(item, progress: progress)
            case .remove:
                self?.handleRemoveProgress(item, progress: progress)
            }
        }
    }
    
    fileprivate func handleMD5Progress(_ item: FileMeta, progress: Progress) {
        mainQueue { [weak self] in
            switch progress {
            case .some(let value):
                self?.progressCircle.animateToDoubleValue(value: value)
            case .done(let hexArray, let errors):
                self?.addHexStrings(hexArray as? [String?] ?? [])
                self?.progressCircle.isHidden = true
                self?.presentErrorsIfNeeded(errors)
            }
        }
    }
    
    fileprivate func handleRemoveProgress(_ item: FileMeta, progress: Progress) {
        mainQueue { [weak self] in
            self?.removeFromTableView(file: item)
            self?.dataStore.remove(item)
            switch progress {
            case .some(let value):
                self?.progressCircle.animateToDoubleValue(value: value)
            case .done(_, let errors):
                self?.progressCircle.isHidden = true
                self?.presentErrorsIfNeeded(errors)
            }
        }
    }
    
    @IBAction private func operationPopBtnValueChanged(_ sender: NSPopUpButton) {
        service.setSelected(operation: FileService.Operation.allCases[sender.indexOfSelectedItem])
    }
}

// MARK: - NSTableViewDelegate
extension FileListViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn,
            let columnIndex = tableView.tableColumns.firstIndex(of: column) else { return nil }
        let type = rowType(atColumn: columnIndex, row: row)
        let factory = TableViewCellHelper.factory(for: type)

        let cell = tableView.makeView(withIdentifier: columns[columnIndex].cellIdentifier,
                                      owner: nil) as? BasicTableCell
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
        operationBtnsAvailability()
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
    
    private func rowType(atColumn column: Int, row: Int) -> CellType? {
        return rows(inColumn: column)[safe: row]
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
