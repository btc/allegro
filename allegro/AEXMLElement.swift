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
    
    // returns the value as Int if possible otherwise fallback
    func safeValueInt(fallback: Int) -> Int {
        let parse = { (input: String) -> Int? in
            return Int(input)
        }
        return safeValue(parse: parse, fallback: fallback)
    }
    
    // TODO figure out how clients can use Int init(String)->Int? with the generic function
    // that way we can remove safeValueInt
    
    // tries to use parse to create T if possible otherwise fallback
    func safeValue<T>(parse: (String) -> T?, fallback: T) -> T {
        if let valueString = self.value {
            return parse(valueString) ?? fallback
        } else {
            return fallback
        }
    }
}
