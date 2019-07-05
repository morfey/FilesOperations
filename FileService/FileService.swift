//
//  FileService.swift
//  FileService
//
//  Created by Tymofii Hazhyi on 7/1/19.
//  Copyright © 2019 Tymofii Hazhyi. All rights reserved.
//

import Foundation
import CommonCrypto

class FileService: NSObject, FileServiceProtocol {
    let fileManager = FileManager.default
    func remove(_ url: URL, completion: ((Error?) -> ())?) {
        do {
            try fileManager.trashItem(at: url, resultingItemURL: nil)
            completion?(nil)
        } catch {
            completion?(error)
        }
    }
    
    func md5File(url: URL, completion: ((String?, Error?) -> ())?) {
        let bufferSize = 1024 * 1024
        
        do {
            let file = try FileHandle(forReadingFrom: url)
            defer {
                file.closeFile()
            }
            
            var context = CC_MD5_CTX()
            CC_MD5_Init(&context)
            
            while autoreleasepool(invoking: {
                let data = file.readData(ofLength: bufferSize)
                if data.count > 0 {
                    data.withUnsafeBytes {
                        _ = CC_MD5_Update(&context, $0.baseAddress, numericCast(data.count))
                    }
                    return true
                } else {
                    return false
                }
            }) { }
            
            var digest: [UInt8] = Array(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            _ = CC_MD5_Final(&digest, &context)
            completion?(digest.map { String(format: "%02hhx", $0) }.joined(), nil)
        } catch {
            print("Cannot open file:", error.localizedDescription)
            completion?(nil, error)
        }
    }
}
