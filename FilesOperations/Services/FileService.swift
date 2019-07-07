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
    public enum Operation: String, CaseIterable {
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
        var hashArray = [String?]()
        files.forEach { [weak self] item in
            self?.remote?.md5File(url: item.url) { hash, error in
                errors.append(error)
                hashArray.append(hash)
                if item != files.last, case let .some(value) = progress {
                    progress = .some(value + step)
                } else {
                    progress = .done(hashArray, errors)
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
