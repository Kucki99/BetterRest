//
//  ContentView.swift
//  BetterRest
//
//  Created by Robin Kuck on 01.06.20.
//  Copyright © 2020 Robin Kuck. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    @State private var sleepAmount = 8.0
    @State private var wakeUpDate = defaultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When do you want to wake up?")) {
                    DatePicker("Please enter a date", selection: $wakeUpDate, in: Date()..., displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                    
                }
                Section(header: Text("Desired Amount of Sleep")) {
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%.2f") hrs")
                    }
                }
                Section(header: Text("Daily Amount of coffee")) {
                    /*
                     Stepper(value: $coffeeAmount, in: 1...20) {
                     if coffeeAmount == 1 {
                     Text("\(coffeeAmount) cup")
                     } else {
                     Text("\(coffeeAmount) cups")
                     }
                     }
                     */
                    Picker(selection: $coffeeAmount, label: Text("Select Amount")) {
                        ForEach(0..<21) { number in
                            Text("\(number) cups")
                        }
                    }
                }
                
                Section(header: Text("Ideal bedtime")) {
                    Text("\(getCalculatedBedtime() ?? "Error")")
                        .font(.headline)
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarTitle("BetterRest")
                /*
            .navigationBarItems(trailing:
                Button(action: calculateBedtime) {
                    Text("Calculate")
                }
            )
                */
        }
        
        /*
         VStack {
         Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
         Text("\(sleepAmount, specifier: "%.2f") hrs")
         }
         
         // Date()... -> one sided range for date in future
         DatePicker("Please enter a date", selection: $wakeUpDate, in: Date()..., displayedComponents: .hourAndMinute)
         .labelsHidden()
         }
         */
    }
    
    func getCalculatedBedtime() -> String? {
        let model = SleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpDate)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUpDate - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return formatter.string(from: sleepTime)
        } catch {
            return nil
        }
    }
    
    func calculateBedtime() {
        let model = SleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpDate)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUpDate - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bedtime is"
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
