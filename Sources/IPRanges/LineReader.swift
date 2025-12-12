//
//  LineReader.swift
//  IPRanges
//
//  Created by Mac on 9/12/25.
//

import Foundation

// Read text file line by line in efficient way
//
// guard let reader = LineReader(from: "/Path/to/file.txt") else {
//    return; // cannot open file
// }
//
// for line in reader {
//    print(">" + line.trimmingCharacters(in: .whitespacesAndNewlines))
// }


// MARK: LineReader
public class LineReader {
    public let path: String
    fileprivate let file: UnsafeMutablePointer<FILE>!
    
    init?(from path: String) {
        self.path = path
        file = fopen(path, "r")
        guard file != nil else {
            return nil
        }
    }
    
    public var nextLine: String? {
        var line: UnsafeMutablePointer<CChar>?
        var linecap: Int = 0
        defer { free(line) }
        return getline(&line, &linecap, file) > 0 ? String(cString: line!) : nil
    }
    
    deinit {
        fclose(file)
    }
}

extension LineReader: Sequence {
    public func makeIterator() -> AnyIterator<String> {
        return AnyIterator<String> {
            // self.trimmingCharacters(in: .whitespacesAndNewlines)
            // return self.nextLine?.replacingOccurrences(of: "\r\n", with: "")
            return self.nextLine
        }
    }
}
