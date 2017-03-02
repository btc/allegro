//
//  PartFileManager.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/28/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import AEXML
import Rational

class PartFileManager : PartStoreObserver {

    private var files = [String]()

    fileprivate let parser = MusicXMLParser()

    private var currentIndex: Int?
    private var currentPartMetadata: PartMetadata?
    private var currentPartStore: PartStore? {
        didSet {
            currentPartStore?.subscribe(self)
        }
    }

    var count: Int {
        return files.count
    }

    fileprivate var currentPart: Int = 0

    init() {
        findParts()
    }

    func findParts() {
        // TODO ls and find all .xml files in Documents and populate files
    }

    // make a new part, save it, and return a part store for it
    func new() -> PartStore {
        let partStore = PartStore(part: Part())
        currentPartStore = partStore
        currentIndex = 0
        files.insert("part_\(count + 1)", at: 0)
        save()
        return partStore
    }

    // Access an XML file from Documents and then parse it as a Part and PartMetadata
    func access(forIndex index: Int) -> (partStore: PartStore, partMetadata: PartMetadata) {

        guard files.indices.contains(index) else {
            Log.error?.message("Unable to find file at index: \(index)")
            return (PartStore(part: Part()), PartMetadata())
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
            let (part, partMetadata) = parser.parse(partDoc: partDoc)

            let partStore = PartStore(part: part)

            return (partStore, partMetadata)

        } catch {
            Log.error?.message("Failed to load XML from Documents. Error: \(error)")
            return (PartStore(part: Part()), PartMetadata())
        }
    }

    // Access an XML file from Documents and then parse it as a Part and PartMetadata
    // set current part store and index
    func load(forIndex index: Int) -> (partStore: PartStore, partMetadata: PartMetadata) {

        let (partStore, partMetadata) = access(forIndex: index)

        currentPartStore = partStore
        currentPartMetadata = partMetadata
        currentIndex = index

        return (partStore, partMetadata)
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
            let (partStore, partMetadata) = parser.parse(partDoc: partDoc)

            return (partStore, partMetadata)

        } catch {
            Log.error?.message("Failed to load XML from Bundle. Error: \(error)")
            return (Part(), PartMetadata())
        }
    }

    // save the current part to disk in Documents.
    // Note: filename should not include .xml extension
    func save() {

        guard let index = currentIndex else {
            Log.error?.message("Need to set current index!")
            return
        }

        guard let partStore = currentPartStore else {
            Log.error?.message("Need to set the current part store!")
            return
        }

        guard files.indices.contains(index) else {
            Log.error?.message("Unable to find file at index: \(index)")
            return
        }
        let filename = files[index]

        Log.info?.message("Generating and saving MuscXML as \(filename).xml")

        // generate XML
        let partDoc = parser.generate(part: partStore.part, partMetadata: PartMetadata())

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

    // save on every change to the part store
    func partStoreChanged() {
        save()
    }
}
