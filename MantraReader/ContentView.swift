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
    
    @State private var selectedMantra: Mantra.ID?
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedMantra) {
                ForEach(mantras, id: \.self) { mantra in
                    NavigationLink(value: mantra.id) {
                        Text("Reads: \(mantra.reads)")
                    }
                    .tag(mantra.id)
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
            if let selectedMantra = mantras.first(where: { $0.id == selectedMantra }) {
                ReadingsView(selectedMantra)
            } else {
                Text("Select a mantra")
                    .foregroundColor(.gray)
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
