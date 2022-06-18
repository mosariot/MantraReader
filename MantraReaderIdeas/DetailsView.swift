//
//  DetailsView.swift
//  MantraReaderIdeas
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI
import Combine

struct DetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var displayedReadings: Double
    @State private var actualReadings: Double
    @State private var actualReadingsString: String = ""
    @State private var deltaReadings: Double = 0
    @State private var actualGoal: Double
    @State private var actualGoalString: String = ""
    @State private var elapsedTime: Double = 0
    @State private var timerReadings = Timer.publish(every: 0.01, on: .main, in: .common)
    @State private var timerSubscription: Cancellable?
    
    init(_ mantra: Mantra) {
        _displayedReadings = State(initialValue: Double(mantra.reads))
        _actualReadings = State(initialValue: Double(mantra.reads))
        _actualGoal = State(initialValue: Double(mantra.goal))
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            NumericTextField("Enter New Readings", text: $actualReadingsString)
                .frame(width: 200)
            Button("Change") {
                actualReadings =  Double(actualReadingsString) ?? 0
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .onChange(of: actualReadings, perform: { newValue in
                deltaReadings = newValue - displayedReadings
                elapsedTime = 0
                timerReadings = Timer.publish(every: 0.01, on: .main, in: .common)
                timerSubscription = timerReadings.connect()
            })
            .onReceive(timerReadings) { _ in
                if elapsedTime < 1.00 {
                    displayedReadings += Double(deltaReadings) / 100.0
                    elapsedTime += 0.01
                } else {
                    displayedReadings = actualReadings
                    actualReadingsString = ""
                    timerSubscription?.cancel()
                }
            }
            
            CircularProgressView(
                progress: actualReadings / actualGoal,
                displayedNumber: displayedReadings
            )
            .frame(width: 200, height: 200)
            .padding()
            
            NumericTextField("Enter New Goal", text: $actualGoalString)
                .frame(width: 200)
                .padding()
            
            Button("Change") {
                actualGoal = Double(actualGoalString) ?? 0
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    @Environment(\.managedObjectContext) static private var viewContext
    static let newMantra = Mantra(context: viewContext)
    
    static var previews: some View {
        DetailsView(newMantra)
    }
}
