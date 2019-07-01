//
//  main.swift
//  FileService
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation

let delegate = FileServiceDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()
