//
//  FileManager-DocumentsDirectory.swift
//  DiceRoll
//
//  Created by Carson Gross on 7/13/22.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
