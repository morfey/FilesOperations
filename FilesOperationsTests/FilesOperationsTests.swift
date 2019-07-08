//
//  FilesOperationsTests.swift
//  FilesOperationsTests
//
//  Created by Tymofii Hazhyi on 6/29/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import XCTest
@testable import FilesOperations

class FilesOperationsTests: XCTestCase {
    let container = DependencyContainer()
    lazy var service = container.makeFileService()
    lazy var dataSource = container.makeDataSource()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        testRemove()
    }
    
    func testTemporaryFilesCreate() {
        dataSource.update(with: dataSource.makeTemporaryFiles())
        XCTAssert(!dataSource.files.isEmpty)
    }
    
    func testMD5Hash() {
        dataSource.update(with: dataSource.makeTemporaryFiles())
        service.setSelected(operation: .md5)
        service.runSelectedOperation(for: dataSource.files) { [weak self] operation, item, progress in
            XCTAssert(operation == .md5)
            switch progress {
            case .done(let hashArray, _):
                XCTAssert(hashArray.count == self?.dataSource.files.count)
            default: break
            }
        }
    }
    
    func testRemove() {
        dataSource.update(with: dataSource.makeTemporaryFiles())
        service.setSelected(operation: .remove)
        service.runSelectedOperation(for: dataSource.files) { operation, item, progress in
            XCTAssert(operation == .remove)
            switch progress {
            case .done: break
            case .some(_):
                XCTAssertFalse(FileManager.default.fileExists(atPath: item.url.path))
            }
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
