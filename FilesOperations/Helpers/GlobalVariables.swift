//
//  GlobalVariables.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation
import AppKit

var application: NSApplication { return NSApplication.shared }
var appDelegate: AppDelegate { return application.delegate as! AppDelegate }

func mainQueue(_ f: @escaping () -> Void) { DispatchQueue.main.async(execute: f) }
