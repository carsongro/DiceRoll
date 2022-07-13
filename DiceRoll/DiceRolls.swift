//
//  DiceRolls.swift
//  DiceRoll
//
//  Created by Carson Gross on 7/13/22.
//

import Foundation

class DiceRolls: ObservableObject {
    @Published var rolls = [Roll]()
    
    let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedData")
    
    init() {
        do {
            let data = try Data(contentsOf: savePath)
            rolls = try JSONDecoder().decode([Roll].self, from: data)
        } catch {
            rolls = []
        }
    }
        func loadData() {
            
        do {
            let data = try Data(contentsOf: savePath)
            rolls = try JSONDecoder().decode([Roll].self, from: data)
        } catch {
            rolls = []
        }
        
    }
    
    func saveData() {
        
        do {
            let data = try JSONEncoder().encode(rolls)
            try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data")
        }
    }
}
