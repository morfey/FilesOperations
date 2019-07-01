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
    let remote: FileServiceProtocol?
    
    init(connection: NSXPCConnection) {
        remote = connection.remoteObjectProxy as? FileServiceProtocol
    }
}
