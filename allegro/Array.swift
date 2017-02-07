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
        let r = self[index..<count]
        return (left: Array(l), right: Array(r))
    }
}
