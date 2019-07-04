//
//  StoryboardName.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation
import AppKit

enum StoryboardName: String {
    case main = "Main"
}

extension NSStoryboard {
    convenience init(name: StoryboardName) {
        self.init(name: name.rawValue, bundle: nil)
    }
    
    func instantiateVC<T: NSViewController>(withIdentifier identifier: String = String(describing: T.self)) -> T {
        return self.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(identifier)) as! T
    }
}
