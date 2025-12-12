//
//  FileManager+Extension.swift
//
//  Created by Mac on 12/12/25.
//

import Foundation

extension FileManager {
    /// Creates a directory and subdirectories at the specified path.
    ///
    /// - Parameter directory: String
    ///
    /// - Returns: Bool
    func create(directory: String) -> Bool {
        if !self.fileExists(atPath: directory) {
            do {
                try self.createDirectory(atPath: directory,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
            } catch {
                print("Unable to create the directory `\(directory)`. Error: \(error.localizedDescription)")
                return false
            }
        }
        return true
    }
}
