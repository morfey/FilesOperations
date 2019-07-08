//
//  AppDelegate.swift
//  FilesOperations
//
//  Created by Tymofii Hazhyi on 6/29/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var controller: NSWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let container = DependencyContainer()
        let listViewController = container.makeFilesListViewController()
        
        controller = NSStoryboard(name: .main).instantiateInitialController() as? NSWindowController
        controller?.contentViewController = listViewController
        controller?.window?.makeKeyAndOrderFront(nil)
    }
    
    @IBAction private func addFilesBtnTapped(_ sender: Any) {
        let vc = (controller?.contentViewController as? FileListViewController)
        vc?.addFilesBtnTapped(sender)
    }
    
    @IBAction private func removeOperationBtnTapped(_ sender: Any) {
        let vc = (controller?.contentViewController as? FileListViewController)
        vc?.setOperation(.remove)
        vc?.runBtnTapped(sender)
    }
    
    @IBAction private func md5OperationBtnTapped(_ sender: Any) {
        let vc = (controller?.contentViewController as? FileListViewController)
        vc?.setOperation(.md5)
        vc?.runBtnTapped(sender)
    }
}
