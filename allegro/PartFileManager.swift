//
//  PartFileManager.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/28/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import AEXML
import Rational

// This class organizes the part files on disk
// Allows clients to save and open them
class PartFileManager {

    static var count: Int {
        return files.count
    }

    static func nextFilename() -> String {
        return "part_\(files.count)"
    }

    static var files: [String] {
        get {
            do {
                let documentDirURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

                // Get the directory contents urls (including subfolders urls)
                let directoryContents = try FileManager.default.contentsOfDirectory(at: documentDirURL,
                                                                                    includingPropertiesForKeys: nil, options: [])

                let xmlFiles = directoryContents.filter{ $0.pathExtension == "xml" }
                return xmlFiles.map{ $0.deletingPathExtension().lastPathComponent }

            } catch {
                Log.error?.message("Failed to search for XML files in Documents. Error: \(error)")
                return [String]()
            }
        }
    }

    // make a new part, save it, and return a part store for it
    static func new() -> (part: Part, partMetadata: PartMetadata) {
        let part = Part()
        let partMetadata = PartMetadata()

        return (part, partMetadata)
    }


    static func loadMostRecent() -> (part: Part, partMetadata: PartMetadata) {
        if let filename = files.last {
            return load(filename: filename)
        } else {
            return new()
         }
    }

    static func load(filename: String) -> (part: Part, partMetadata: PartMetadata) {

        guard files.contains(filename) else {
            Log.error?.message("Unable to find file: \(filename)")
            return (Part(), PartMetadata())
        }

        Log.info?.message("reading MusicXML from \(filename).xml")

        do {
            let documentDirURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

            // Find the file
            let fileURL = documentDirURL.appendingPathComponent(filename).appendingPathExtension("xml")
            Log.debug?.message("fileURL: \(fileURL.absoluteString)")

            // Load XML from file
            let data = try Data(contentsOf: fileURL)

            // Parse XML
            let partDoc = try AEXMLDocument(xml: data)
            let (part, partMetadata) = MusicXMLParser.parse(partDoc: partDoc)

            return (part, partMetadata)

        } catch {
            Log.error?.message("Failed to load XML from Documents. Error: \(error)")
            return (Part(), PartMetadata())
        }
    }

    // attempts to load a file as XML and then parse it as a Part and PartMetadata
    static func bundleLoad(filename: String) -> (Part, PartMetadata) {
        Log.info?.message("reading MusicXML from \(filename).xml")

        do {
            // Find the file
            guard let filePath = Bundle.main.path(forResource: filename, ofType: "xml") else {
                Log.error?.message("Unable to open file from bundle")
                return (Part(), PartMetadata())
            }

            let fileURL = URL(fileURLWithPath: filePath)
            Log.debug?.message("fileURL: \(fileURL.absoluteString)")

            // Load XML from file
            let data = try Data(contentsOf: fileURL)

            // Parse XML
            let partDoc = try AEXMLDocument(xml: data)
            let (partStore, partMetadata) = MusicXMLParser.parse(partDoc: partDoc)

            return (partStore, partMetadata)

        } catch {
            Log.error?.message("Failed to load XML from Bundle. Error: \(error)")
            return (Part(), PartMetadata())
        }
    }

    static func save(part: Part, partMetadata: PartMetadata, as filename: String) {

        Log.info?.message("Generating and saving MuscXML as \(filename).xml")

        // generate XML
        let partDoc = MusicXMLParser.generate(part: part, partMetadata: partMetadata)

        do {
            let documentDirURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

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
