//
//  FileService.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation
import FileService

class FileService {
    enum Operation: String, CaseIterable {
        case remove = "Remove"
        case md5 = "MD5"
    }
    
    private let remote: FileServiceProtocol?
    private(set) var selectedOperation: Operation = .remove
    
    init(connection: NSXPCConnection) {
        remote = connection.remoteObjectProxy as? FileServiceProtocol
    }
    
    private func remove(_ files: [FileMeta], completion: ((Operation, FileMeta, Progress) -> ())?) {
        var progress: Progress = .some(0)
        var errors = [Error?]()
        let step = (Double(100) / Double(files.count))
        files.forEach { [weak self] item in
            self?.remote?.remove(item.url) { error in
                errors.append(error)
                if item != files.last, case let .some(value) = progress {
                    progress = .some(value + step)
                } else {
                    progress = .done([], errors)
                }
                completion?(.remove, item, progress)
            }
        }
    }
    
    private func generateMd5(_ files: [FileMeta], completion: ((Operation, FileMeta, Progress) -> ())?) {
        var progress: Progress = .some(0)
        let step = (Double(100) / Double(files.count))
        var errors = [Error?]()
        var hexArray = [String?]()
        files.forEach { [weak self] item in
            self?.remote?.md5File(url: item.url) { hex, error in
                errors.append(error)
                hexArray.append(hex)
                if item != files.last, case let .some(value) = progress {
                    progress = .some(value + step)
                } else {
                    progress = .done(hexArray, errors)
                }
                completion?(.md5, item, progress)
            }
        }
    }
    
    public func setSelected(operation: Operation) {
        selectedOperation = operation
    }
    
    public func runSelectedOperation(for files: [FileMeta], completion: ((Operation, FileMeta, Progress) -> ())?) {
        switch selectedOperation {
        case .remove:
            remove(files, completion: completion)
        case .md5:
            generateMd5(files, completion: completion)
        }
    }
}
