//
//  FileServiceProtocol.swift
//  FileService
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation

@objc public protocol FileServiceProtocol {
    func remove(_ url: URL, completion: @escaping () -> ())
}
