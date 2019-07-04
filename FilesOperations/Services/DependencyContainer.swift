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

protocol ViewControllerFactory {
    func makeFilesListViewController() -> FileListViewController
    func makeErrorListViewController(errors: [String]) -> ErrorListViewController
}

extension DependencyContainer: ViewControllerFactory {
    func makeFilesListViewController() -> FileListViewController {
        return FileListViewController.makeFromStoryboard(with: self)
    }
    
    func makeErrorListViewController(errors: [String]) -> ErrorListViewController {
        return ErrorListViewController(errors: errors)
    }
}

protocol FileServiceFactory {
    func makeFileService() -> FileService
}

protocol DataSouceFactory {
    func makeDataSource() -> DataSource
}

extension DependencyContainer: FileServiceFactory {
    func makeFileService() -> FileService {
        return FileService(connection: xpcConnection)
    }
}

extension DependencyContainer: DataSouceFactory {
    func makeDataSource() -> DataSource {
        return DataSource()
    }
}
