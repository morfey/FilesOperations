//
//  Progress.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 7/2/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation
import AppKit

public class ProgressBarAnimation: NSAnimation {
    let newValue: Double
    let indicator: NSProgressIndicator
    let initialValue: Double
    
    init(_ progressIndicator: NSProgressIndicator, newValue: Double) {
        self.newValue = newValue
        self.indicator = progressIndicator
        self.initialValue = progressIndicator.doubleValue
        super.init(duration: 0.1, animationCurve: .easeIn)
        self.animationBlockingMode = .nonblocking
    }
    
    required public init?(coder aDecoder: NSCoder) {
        indicator = NSProgressIndicator()
        initialValue = 0
        newValue = 0
        super.init(coder: aDecoder)
    }
    
    override public var currentProgress: NSAnimation.Progress {
        didSet {
            let diff = newValue - initialValue
            indicator.doubleValue = initialValue + (diff * Double(currentProgress))
        }
    }
}

extension NSProgressIndicator {
    func animateToDoubleValue(value: Double) {
        ProgressBarAnimation(self, newValue: value).start()
    }
}
