//
//  main.swift
//
//  Created by Mac on 11/12/25.
//

import Foundation
import ArgumentParser

// Optimization for reduce the size of the original CSV file
//
// - Remove the double quotes.
//
// cat IP-COUNTRY.csv | tr -d \" > IP-COUNTRY.csv
//

// MARK: Converter
struct Converter: ParsableCommand {
    @Argument(help: "The path of the file to parse (default: `\\.IP-COUNTRY.csv`).")
    var input: String?
    @Option(help: "The directory path to save the parse results (default: `\\.`) .")
    var output: String?
    @Flag(help: "Decompress the input file with lzma (`.7z`).")
    var decompress: Bool = false
    @Flag(help: "Compress the input file with lzma (`.7z`).")
    var compress: Bool = false
    
    // Default directory is current directory
    fileprivate var defaultDirectory: URL {
        return URL.currentDirectory()
    }
    // Default input file is in default input directory
    fileprivate var inputFile: URL {
        guard let input = input else {
            return defaultDirectory.appendingPathComponent("IP-COUNTRY.csv")
        }
        return URL(fileURLWithPath: input)
    }
    // Default output directory is the same of the input file
    fileprivate var outputDirectory: URL {
        guard let output = output else {
            return inputFile.deletingLastPathComponent()
        }
        return URL(fileURLWithPath: output, isDirectory: true)
    }
    
    /// Compress the input `csv`file .
    /// 
    /// - Parameter inputFile: input `csv` file.
    /// - Parameter outputDirectory: URL?
    ///
    /// - Note
    /// If the outputDirectory is nil the output  `.7z` file will be in the same directory and with the same name that the original file.
    ///
    /// - Returns: Output file URL
    fileprivate func compressFile(inputFile: URL) -> URL? {
        let outputFile = outputDirectory.appending(path: inputFile.lastPathComponent).deletingPathExtension().appendingPathExtension("7z")
        let decompressing = Date()
        if Compressor.compress(from: inputFile, to: outputFile) {
            print("The input file `\(inputFile.lastPathComponent)` has been compressed into `\(outputFile.lastPathComponent)` sucessfully in \(Date().timeIntervalSince(decompressing)).")
            return outputFile
        }
        return nil
    }
    /// Compress the input `.7z`file .
    /// 
    /// - Parameter inputFile: Input `.7z` file.
    /// - Parameter outputDirectory: URL?
    ///
    /// - Note
    ///   If the outputDirectory is nil the output  `.csv` file will be in the same directory and with the same name that the original file.
    ///
    /// - Returns: Output file URL
    fileprivate func decompressFile(inputFile: URL) -> URL? {
        let outputFile = outputDirectory.appending(path: inputFile.lastPathComponent).deletingPathExtension().appendingPathExtension("csv")
        let compressing = Date()
        if Compressor.decompress(from: inputFile, to: outputFile) {
            print("The input file `\(inputFile.lastPathComponent)` has been decompressed into `\(outputFile.lastPathComponent)` sucessfully in \(Date().timeIntervalSince(compressing)).")
            return outputFile
        }
        return nil
    }
    
    /// Perform the data conversion
    ///
    /// - Parameter inputFile:  Input `.cvs` file.
    ///
    fileprivate func performConversion(inputFile: URL) {
        let converter = IPRangesConverter()
        print("Loading conversion data.")
        if converter.load(from: inputFile) {
            print("Conversion data has been loaded sucessfully.")
            let converting = Date()
            if converter.runAndSave(to: outputDirectory) {
                print("Conversion has been completed sucessfully in \(Date().timeIntervalSince(converting))")
            }
        } else {
            print("Conversion failed. Unexpected error.")
        }
    }

    mutating func run() throws {

        // Create the output directory if needed
        if FileManager.default.create(directory: outputDirectory.path()) {
            print("Output directory `\(outputDirectory)` was created sucessfully.")
        }
        
        // Compress input file if needed
        if compress {
            // $0 INPUT.csv --compress
            print("Compressing `\(inputFile)` with lzma to `\(outputDirectory)` started.")
            if let outputFile = compressFile(inputFile: inputFile) {
                print("The input file `\(inputFile.lastPathComponent)` has been compressed sucessfully `\(outputFile.lastPathComponent)`.")
            }
        // Decompress input file if needed
        } else if decompress {
            // $0 INPUT.7z --decompress
            print("Decompressing `\(inputFile)` with lzma to `\(outputDirectory)` started.")
            if let outputFile = decompressFile(inputFile: inputFile) {
                performConversion(inputFile: outputFile)
            }
        }  else {
            // $0 \.IP-COUNTRY.csv \.
            print("Conversion of `\(inputFile)` to `\(outputDirectory)` started.")
            performConversion(inputFile: inputFile)
        }
    }
}

Converter.main()
