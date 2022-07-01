//
//  ReadsView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI

struct ReadsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ObservedObject var viewModel: ReadsViewModel
    @State private var readings: Int32 = 0
    @State private var goal: Int32 = 0
    
#if os(iOS)
    private var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
#endif
    
    var body: some View {
        let layout = (horizontalSizeClass == .regular && isPhone) ? AnyLayout(HStack()) : AnyLayout(VStack())
        
        layout {
            Spacer()
            
            VStack {
                TextField("Enter New Readings", value: $readings, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                
                Button("Change") {
                    viewModel.animateReadsChanges(with: readings)
                    readings = 0
                    saveContext()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            
            CircularProgressView(
                progress: viewModel.progress,
                displayedNumber: viewModel.displayedReads,
                displayedGoal: viewModel.displayedGoal,
                isAnimated: viewModel.isAnimated
            )
            .padding()
            
            VStack {
                TextField("Enter New Goal", value: $goal, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 200)
                    .padding()
                
                Button("Change") {
                    viewModel.animateGoalsChanges(with: goal)
                    goal = 0
                    saveContext()
                }
                .buttonStyle(.borderedProminent)
            }
            
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

import CoreData

struct ReadsView_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    static func previewMantra(viewContext: NSManagedObjectContext) -> Mantra {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try mantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return mantras[Int.random(in: 0...mantras.count-1)]
    }
    
    static var previews: some View {
        ReadsView(viewModel: ReadsViewModel(previewMantra(viewContext: controller.container.viewContext)))
            .environment(\.managedObjectContext, controller.container.viewContext)
    }
}
