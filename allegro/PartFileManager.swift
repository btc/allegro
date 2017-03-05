//
//  PartFileManager.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/28/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import AEXML
import Rational
import Foundation

// This class organizes the part files on disk
// Allows clients to save and open them
class PartFileManager {

    private static let fileManager = FileManager.default

    static var count: Int {
        return files.count
    }

    static func nextFilename() -> String {
        return "part_\(files.count)"
    }

    // return all the .xml files in the Documents folder, sorted by last modified time (most recent first)
    static var files: [(filename: String, modified: Date)] {
        get {
            do {
                let documentDirURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

                // Get the directory contents urls (including subfolders urls)
                let directoryContents = try fileManager.contentsOfDirectory(at: documentDirURL,
                                                                                    includingPropertiesForKeys: nil, options: [])

                let xmlFiles = directoryContents.filter{ $0.pathExtension == "xml" }

                var files = [(filename: String, modified: Date)]()
                for fileURL in xmlFiles {

                    let filename = fileURL.deletingPathExtension().lastPathComponent

                    let filePath = fileURL.pathComponents.joined(separator: "/")

                    let attributes = try fileManager.attributesOfItem(atPath: filePath) as NSDictionary
                    let modified = attributes.fileModificationDate() ?? Date()

                    Log.debug?.message("Found file: \(filename).xml, modified: \(modified)")

                    files.append((filename, modified))
                }
                
                // sort files by modified time. > bc we want larger dates (most recent ones) first
                return files.sorted(by: { (e1, e2) -> Bool in e1.modified > e2.modified })

            } catch {
                Log.error?.message("Failed to search for XML files in Documents. Error: \(error)")
                return [(String, Date)]()
            }
        }
    }

    static func mostRecentFilename() -> String? {
//        return files.sorted(by: { (e1, e2) -> Bool in e1.modified < e2.modified }).first?.filename
        return files.first?.filename
    }

    static func load(filename: String) -> Part {

        guard files.contains(where: { $0.filename == filename } ) else {
            Log.error?.message("Unable to find file: \(filename)")
            return Part()
        }

        Log.info?.message("reading MusicXML from \(filename).xml")

        do {
            let documentDirURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

            // Find the file
            let fileURL = documentDirURL.appendingPathComponent(filename).appendingPathExtension("xml")
            Log.debug?.message("fileURL: \(fileURL.absoluteString)")

            // Load XML from file
            let data = try Data(contentsOf: fileURL)

            // Parse XML
            let partDoc = try AEXMLDocument(xml: data)
            return MusicXMLParser.parse(partDoc: partDoc)

        } catch {
            Log.error?.message("Failed to load XML from Documents. Error: \(error)")
            return Part()
        }
    }

    // attempts to load a file as XML and then parse it as a Part and PartMetadata
    static func bundleLoad(filename: String) -> Part {
        Log.info?.message("reading MusicXML from \(filename).xml")

        do {
            // Find the file
            guard let filePath = Bundle.main.path(forResource: filename, ofType: "xml") else {
                Log.error?.message("Unable to open file from bundle")
                return Part()
            }

            let fileURL = URL(fileURLWithPath: filePath)
            Log.debug?.message("fileURL: \(fileURL.absoluteString)")

            // Load XML from file
            let data = try Data(contentsOf: fileURL)

            // Parse XML
            let partDoc = try AEXMLDocument(xml: data)
            return MusicXMLParser.parse(partDoc: partDoc)

        } catch {
            Log.error?.message("Failed to load XML from Bundle. Error: \(error)")
            return Part()
        }
    }

    static func save(part: Part, as filename: String) {

        Log.info?.message("Generating and saving MuscXML as \(filename).xml")

        // generate XML
        let partDoc = MusicXMLParser.generate(part: part)

        do {
            let documentDirURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

            // Find the file
            let fileURL = documentDirURL.appendingPathComponent(filename).appendingPathExtension("xml")
            Log.debug?.message("fileURL: \(fileURL.absoluteString)")

            // Write XML to the file
            try partDoc.xml.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)

        } catch {
            Log.error?.message("Failed to save XML. Error: \(error)")
        }
    }

}
