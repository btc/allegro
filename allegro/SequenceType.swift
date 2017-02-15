//
//  SequenceType.swift
//  allegro
//
//  Created by Qingping He on 2/13/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

import Foundation

public extension Sequence {
    
    /// Categorises elements of self into a dictionary, with the keys given by keyFunc
    
    func categorize<U : Hashable>(keyFunc: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}
