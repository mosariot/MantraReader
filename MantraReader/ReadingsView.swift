//
//  ReadingsView.swift
//  MantraReaderIdeas
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI
import Combine
import CoreData

struct ReadingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var mantra: Mantra
    @State var displayedReadings: Double
    @State private var actualReadingsString: String = ""
    @State private var deltaReadings: Double = 0
    @State private var actualGoalString: String = ""
    @State private var elapsedTime: Double = 0
    @State private var timerReadings = Timer.publish(every: 0.01, on: .main, in: .common)
    @State private var timerSubscription: Cancellable?
    @State private var isAnimated: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            NumericTextField("Enter New Readings", text: $actualReadingsString)
                .frame(width: 200)
            
            Button("Change") {
                isAnimated = true
                mantra.reads = Int32(actualReadingsString) ?? mantra.reads
                saveContext()
                actualReadingsString = ""
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .onChange(of: mantra.reads, perform: { newValue in
                if isAnimated {
                    deltaReadings = Double(newValue) - displayedReadings
                    elapsedTime = 0
                    timerReadings = Timer.publish(every: 0.01, on: .main, in: .common)
                    timerSubscription = timerReadings.connect()
                } else {
                    displayedReadings = Double(newValue)
                }
            })
            .onReceive(timerReadings) { _ in
                if elapsedTime < 1.00 {
                    displayedReadings += Double(deltaReadings) / 100.0
                    elapsedTime += 0.01
                } else {
                    displayedReadings = Double(mantra.reads)
                    timerSubscription?.cancel()
                    isAnimated = false
                }
            }
            
            CircularProgressView(
                progress: Double(mantra.reads) / Double(mantra.goal),
                displayedNumber: displayedReadings,
                isAnimated: isAnimated
            )
            .frame(width: 200, height: 200)
            .padding()
            
            Text("Current goal: \(mantra.goal)")
                .foregroundColor(.gray)
            
            NumericTextField("Enter New Goal", text: $actualGoalString)
                .frame(width: 200)
                .padding()
            
            Button("Change") {
                isAnimated = true
                mantra.goal = Int32(actualGoalString) ?? mantra.goal
                saveContext()
                actualGoalString = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isAnimated = false
                }
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

struct ReadingsView_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    
    static var previews: some View {
        ReadingsView(mantra: controller.savedData.first!, displayedReadings: Double(controller.savedData.first!.reads))
            .environment(\.managedObjectContext, controller.container.viewContext)
    }
}
