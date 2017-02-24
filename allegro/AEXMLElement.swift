//
//  AEXMLElement.swift
//  allegro
//
//  Created by Nikhil Lele on 2/24/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import AEXML
extension AEXMLElement {
    
    // returns all children whose name matches the input
    func childrenMatch(name: String) -> [AEXMLElement] {
        return children.filter({$0.name == name})
    }
    
    // returns the first child whose name matches the input
    func firstChildMatch(name: String) -> AEXMLElement? {
        return childrenMatch(name: name).first
    }
    
    // TODO safe value for any type
    // returns the value as Int if possible otherwise fallback
    func safeValueInt(fallback: Int) -> Int {
        if let valueString = self.value {
            return Int(valueString) ?? fallback
        } else {
            return fallback
        }
    }
}
