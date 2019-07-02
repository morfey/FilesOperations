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
    
    func remove(urls: [URL], completion: ((URL, Double)->())?) {
        var progress: Double = 0
        let step = (Double(100) / Double(urls.count))
        urls.forEach { [weak self] item in
            self?.remote?.remove(item) {
                progress += step
                completion?(item, progress)
            }
        }
    }
}
