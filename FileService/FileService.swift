//
//  FileService.swift
//  FileService
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation

class FileService: NSObject, FileServiceProtocol {
    let fileManager = FileManager.default
    func remove(_ url: URL, completion: (() -> ())?) {
        do {
            try fileManager.removeItem(at: url)
            completion?()
        } catch {
        
        }
    }
}
