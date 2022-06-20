//
//  ContentView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 19.06.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
        
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Mantra.reads, ascending: false)],
        animation: .default)
    private var mantras: FetchedResults<Mantra>
    
    @State private var selectedMantra: Mantra?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedMantra) {
                ForEach(mantras) { mantra in
                    NavigationLink(value: mantra) {
                        Text("Reads: \(mantra.reads)")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Mantra Reader")
        } detail: {
            ZStack {
                if let selectedMantra {
                    ReadingsView(mantra: selectedMantra, displayedReadings: Double(selectedMantra.reads))
                } else {
                    Text("Select a mantra")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newMantra = Mantra(context: viewContext)
            newMantra.reads = Int32.random(in: 0...1000)
            saveContext()
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { mantras[$0] }.forEach(viewContext.delete)
            saveContext()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
