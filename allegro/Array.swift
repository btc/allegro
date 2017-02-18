//
//  Array.swift
//  allegro
//
//  Created by Brian Tiger Chow on 2/6/17.
//  Copyright © 2017 gigaunicorn. All rights reserved.
//

extension Array {
    func partition(index: Int) -> (left: Array, right: Array) {
        let l = self[0..<index]
        let r = self[index..<count] // TODO(btc): maybe use stride
        return (left: Array(l), right: Array(r))
    }

    func indexOfFirstMatch(_ condition: (Element) -> Bool) -> Index? {
        var low = startIndex
        var high = endIndex
        var found = false
        while low < high {
            let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
            if condition(self[mid]) {
                high = mid
                found = true
            } else {
                low = index(after: mid)
            }
        }
        return found ? low : nil
    }
}
