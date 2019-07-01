//
//  DependencyContainer.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation
import FileService

class DependencyContainer {
    private lazy var xpcConnection: NSXPCConnection = {
        let connection = NSXPCConnection(serviceName: "com.timh.FileService")
        connection.remoteObjectInterface = NSXPCInterface(with: FileServiceProtocol.self)
        connection.resume()
        return connection
    }()
}

extension DependencyContainer: ViewControllerFactory {
    func makeFilesListViewController() -> FileListViewController {
        return FileListViewController.makeFromStoryboard(with: self)
    }
}

extension DependencyContainer: FileServiceFactory, DataSouceFactory {
    func makeFileService() -> FileService {
        return FileService(connection: xpcConnection)
    }
    
    func makeDataSource() -> DataSource {
        return DataSource()
    }
}

protocol ViewControllerFactory {
    func makeFilesListViewController() -> FileListViewController
}

protocol FileServiceFactory {
    func makeFileService() -> FileService
}

protocol DataSouceFactory {
    func makeDataSource() -> DataSource
}
