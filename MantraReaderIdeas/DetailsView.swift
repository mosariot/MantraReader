//
//  DetailsView.swift
//  MantraReaderIdeas
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI
import Combine
import CoreData

struct DetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var mantra: Mantra
    @State private var displayedReadings: Double
    @State private var actualReadingsString: String = ""
    @State private var deltaReadings: Double = 0
    @State private var actualGoalString: String = ""
    @State private var elapsedTime: Double = 0
    @State private var timerReadings = Timer.publish(every: 0.01, on: .main, in: .common)
    @State private var timerSubscription: Cancellable?
    
    init(_ mantra: Mantra) {
        _mantra = State(initialValue: mantra)
        _displayedReadings = State(initialValue: Double(mantra.reads))
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            NumericTextField("Enter New Readings", text: $actualReadingsString)
                .frame(width: 200)
            
            Button("Change") {
                mantra.reads = Int32(actualReadingsString) ?? mantra.reads
                saveContext()
                actualReadingsString = ""
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .onChange(of: mantra.reads, perform: { newValue in
                deltaReadings = Double(newValue) - displayedReadings
                elapsedTime = 0
                timerReadings = Timer.publish(every: 0.01, on: .main, in: .common)
                timerSubscription = timerReadings.connect()
            })
            .onReceive(timerReadings) { _ in
                if elapsedTime < 1.00 {
                    displayedReadings += Double(deltaReadings) / 100.0
                    elapsedTime += 0.01
                } else {
                    displayedReadings = Double(mantra.reads)
                    timerSubscription?.cancel()
                }
            }
            
            CircularProgressView(
                progress: Double(mantra.reads) / Double(mantra.goal),
                displayedNumber: displayedReadings
            )
            .frame(width: 200, height: 200)
            .padding()
            
            Text("Current goal: \(mantra.goal)")
                .foregroundColor(.gray)
            
            NumericTextField("Enter New Goal", text: $actualGoalString)
                .frame(width: 200)
                .padding()
            
            Button("Change") {
                mantra.goal = Int32(actualGoalString) ?? mantra.goal
                saveContext()
                actualGoalString = ""
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
    
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) static private var viewContext
    
    static private var newMantra: Mantra {
        let m = Mantra(context: viewContext)
        m.reads = Int32.random(in: 0...100)
        return m
    }
    
    static var previews: some View {
        DetailsView(newMantra)
    }
}
