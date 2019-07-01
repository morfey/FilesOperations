//
//  FileServiceDelegate.swift
//  FileService
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation

class FileServiceDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        let exportedObject = FileService()
        newConnection.exportedInterface = NSXPCInterface(with: FileServiceProtocol.self)
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
}
