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

    var count: Int {
        return files.count
    }

    fileprivate var currentPart: Int = 0

    func nextFilename() -> String {
        return "part_\(files.count)"
    }

    var files: [String] {
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
    func new() -> (part: Part, partMetadata: PartMetadata) {
        let filename = nextFilename()

        let part = Part()
        var partMetadata = PartMetadata()
        partMetadata.title = filename

        save(part: part, partMetadata: partMetadata, as: filename)

        for f in files {
            Log.info?.message("FILE: \(f)")
        }

        return (part, partMetadata)
    }

    // Access an XML file from Documents and then parse it as a Part and PartMetadata
    func access(forIndex index: Int) -> (part: Part, partMetadata: PartMetadata) {

        guard files.indices.contains(index) else {
            Log.error?.message("Unable to find file at index: \(index)")
            return (Part(), PartMetadata())
        }
        let filename = files[index]

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

    func loadMostRecent() -> (part: Part, partMetadata: PartMetadata) {
        if let filename = files.last {
            return load(filename: filename)
        } else {
            return (Part(), PartMetadata())
        }
    }

    // Access an XML file from Documents and then parse it as a Part and PartMetadata
    // set current part store and index
    func load(forIndex index: Int) -> (part: Part, partMetadata: PartMetadata) {

        let (partStore, partMetadata) = access(forIndex: index)
        return (partStore, partMetadata)
    }

    func load(filename: String) -> (part: Part, partMetadata: PartMetadata) {

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
    func bundleLoad(filename: String) -> (Part, PartMetadata) {
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

    func save(part: Part, partMetadata: PartMetadata, as filename: String) {

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
