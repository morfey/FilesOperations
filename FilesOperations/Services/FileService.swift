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
    private let remote: FileServiceProtocol?
    
    init(connection: NSXPCConnection) {
        remote = connection.remoteObjectProxy as? FileServiceProtocol
    }
    
    func remove(_ files: [FileMeta], completion: ((FileMeta, Progress) -> ())?) {
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
                completion?(item, progress)
            }
        }
    }
    
    func generateMd5(_ files: [FileMeta], completion: ((FileMeta, Progress) -> ())?) {
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
                completion?(item, progress)
            }
        }
    }
}
