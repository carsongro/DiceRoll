//
//  ContentView.swift
//  DiceRoll
//
//  Created by Carson Gross on 7/13/22.
//

import SwiftUI
import CoreHaptics

struct ContentView: View {
    @StateObject var diceRolls = DiceRolls()
    @State private var engine: CHHapticEngine?
    
    @State private var roll1 = Int.random(in: 1...6)
    @State private var roll2 = Int.random(in: 1...6)
    @State private var diceSize = 6
    @FocusState private var diceSizeIsFocused: Bool
    @State private var counter = 0
    @State private var isActive = false
    
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    var diceCorrectSize: Bool {
        if diceSize > 0 && diceSize < 101 {
            return true
        }
        return false
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                Section {
                    VStack {
                        HStack {
                            VStack {
                                Text("Die 1:")
                                    .font(.largeTitle)
                                Text("\(roll1)")
                                    .font(.title)
                                    .foregroundColor(isActive ? .red : .green)
                            }
                            .padding()
                            
                            Spacer()
                            
                            Section {
                                Text("Total: \(roll1 + roll2)")
                            }
                            .frame(maxWidth: .infinity)
                            
                            Spacer()
                            
                            VStack {
                                Text("Die 2:")
                                    .font(.largeTitle)
                                Text("\(roll2)")
                                    .font(.title)
                                    .foregroundColor(isActive ? .red : .green)
                            }
                            .padding()
                        }
                        .padding()
                        
                        Section {
                            Form {
                                Text("Please enter the size of the dice:")
                                TextField("Dice Size", value: $diceSize, format: .number)
                                    .keyboardType(.decimalPad)
                                    .focused($diceSizeIsFocused)
                            }
                        }
                    }
                }
                
                Section {
                    if diceCorrectSize {
                        Button {
                            rollDice()
                            isActive = true
                        } label: {
                            Text("Roll Dice")
                        }
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .onAppear(perform: prepareHaptics)
                        .onTapGesture(perform: complexSuccess)
                        .onReceive(timer) { time in
                            guard isActive else { return }
                            roll1 = Int.random(in: 1...diceSize)
                            roll2 = Int.random(in: 1...diceSize)
                            counter -= 1
                        }
                        
                    } else {
                        Text("Please enter a size between 1 and 100.")
                    }
                }
                
                Section {
                    List {
                        ForEach(diceRolls.rolls) { roll in
                            Text("\(roll.dice1), \(roll.dice2), Total: \(roll.dice1 + roll.dice2)")
                        }
                    }
                }
            }
            .navigationTitle("Roll Dice")
            .onAppear(perform: diceRolls.loadData)
        }
    }
    
    func rollDice() {
        counter = 7
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isActive = false
            roll1 = Int.random(in: 1...diceSize)
            roll2 = Int.random(in: 1...diceSize)
            let newRoll = Roll(dice1: roll1, dice2: roll2)
            diceRolls.rolls.insert(newRoll, at: 0)
            diceRolls.saveData()
        }
    }
    
    func complexSuccess() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
