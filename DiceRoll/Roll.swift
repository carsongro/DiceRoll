//
//  Roll.swift
//  DiceRoll
//
//  Created by Carson Gross on 7/13/22.
//

import Foundation

struct Roll: Codable, Identifiable {
    var id = UUID()
    let dice1: Int
    let dice2: Int
}
