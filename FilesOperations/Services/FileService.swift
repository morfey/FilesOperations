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
    
    func remove(_ files: [FileMeta], completion: ((FileMeta, Double) -> ())?) {
        var progress: Double = 0
        let step = (Double(100) / Double(files.count))
        files.forEach { [weak self] item in
            self?.remote?.remove(item.url) {
                if item != files.last {
                    progress += step
                } else {
                    progress = 100
                }
                completion?(item, progress)
            }
        }
    }
    
    func generateMd5(_ files: [FileMeta], completion: ((FileMeta, Double) -> ())?) {
        var progress: Double = 0
        let step = (Double(100) / Double(files.count))
        files.forEach { [weak self] item in
            self?.remote?.md5File(url: item.url) { _ in
                if item != files.last {
                    progress += step
                } else {
                    progress = 100
                }
                completion?(item, progress)
            }
        }
    }
}
