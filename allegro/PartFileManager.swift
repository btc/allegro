//
//  PartFileManager.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/28/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import AEXML
import Rational

class PartFileManager {

    private var files = [String]()

    fileprivate let parser = MusicXMLParser()

    var count: Int {
        return files.count
    }

    init() {
        // add part for testing
        let p = Part()
        p.title = "ExamplePart"
        let n = Note(value: .quarter, letter: .C, octave: 5)
        let _ = p.insert(note: n, intoMeasureIndex: 0, at: 1/4)
        files.append("ExampleFile")
        save(forIndex: 0, part: p)
    }

    func findParts() {
        // TODO ls and find all .xml files in Documents and populate files
    }

    // Load an XML file from Documents and then parse it as a Part
    // Note filename should not include .xml extension
    func load(forIndex index: Int) -> Part {

        guard files.indices.contains(index) else {
            Log.error?.message("Unable to find file at index: \(index)")
            return Part()
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
            let part = parser.parse(partDoc: partDoc)

            return part

        } catch {
            Log.error?.message("Failed to load XML from Documents. Error: \(error)")
            return Part()
        }
    }

    // attempts to load a file as XML and then parse it as a Part
    func bundleLoad(filename: String) -> Part? {
        Log.info?.message("reading MusicXML from \(filename).xml")

        do {
            // Find the file
            guard let filePath = Bundle.main.path(forResource: filename, ofType: "xml") else {
                Log.error?.message("Unable to open file from bundle")
                return nil
            }

            let fileURL = URL(fileURLWithPath: filePath)
            Log.debug?.message("fileURL: \(fileURL.absoluteString)")

            // Load XML from file
            let data = try Data(contentsOf: fileURL)

            // Parse XML
            let partDoc = try AEXMLDocument(xml: data)
            return parser.parse(partDoc: partDoc)

        } catch {
            Log.error?.message("Failed to load XML from Bundle. Error: \(error)")
            return Part()
        }
    }

    // save the Part to disk in Documents.
    // Note: filename should not include .xml extension
    func save(forIndex index: Int, part: Part) {

        guard files.indices.contains(index) else {
            Log.error?.message("Unable to find file at index: \(index)")
            return
        }
        let filename = files[index]

        Log.info?.message("Generating and saving MuscXML as \(filename).xml")

        // generate XML
        let partDoc = parser.generate(part: part)

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

