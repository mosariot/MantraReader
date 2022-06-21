//
//  MantraListView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI

struct MantraListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Mantra.reads, ascending: false)],
        animation: .default)
    private var mantras: FetchedResults<Mantra>
    
    @Binding var selectedMantra: Mantra?
    
    var body: some View {
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
            ToolbarItem(placement: .navigationBarLeading) {
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
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { mantras[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func addItem() {
        withAnimation {
            let newMantra = Mantra(context: viewContext)
            newMantra.reads = Int32.random(in: 0...1000)
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

struct MantraListView_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    @State static var mantra = controller.mantras.first
    
    static var previews: some View {
        MantraListView(selectedMantra: $mantra)
            .environment(\.managedObjectContext, controller.container.viewContext)
    }
}


