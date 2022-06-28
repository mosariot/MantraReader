//
//  MantraListColumn.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI

enum Sorting: String, Codable {
    case title
    case reads
}

struct MantraListColumn: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var orientationInfo: OrientationInfo
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    @AppStorage("sorting") private var sorting: Sorting = .title
    
    @FetchRequest(sortDescriptors: [sortDescriptor], animation: .default)
    private var mantras: FetchedResults<Mantra>
    
    var sortDescriptor: NSSortDescriptor {
        switch sorting {
            case .title:
            return NSSortDescriptor(keyPath: \Mantra.title, ascending: true)
            case .reads:
            return NSSortDescriptor(keyPath: \Mantra.reads, ascending: false)
        }
    }
    @Binding var selectedMantra: Mantra?
    
    var body: some View {
        List(selection: $selectedMantra) {
            Section(header: Text("Favorites")) {
                ForEach(mantras.filter { $0.isFavorite } ) { mantra in
                    NavigationLink(value: mantra) {
                        MantraRow(mantra: mantra, isSelected: mantra === selectedMantra)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .headerProminence(.increased)
                
            Section(header: Text("Other Mantras")) {
                ForEach(mantras.filter { !$0.isFavorite } ) { mantra in
                    NavigationLink(value: mantra) {
                        MantraRow(mantra: mantra, isSelected: mantra === selectedMantra)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .headerProminence(.increased)
        }
        .listStyle(.insetGrouped)
        .onAppear {
            if let mantra = mantras.first {
#if os(iOS)
                if (UIDevice.current.userInterfaceIdiom == .phone &&
                    orientationInfo.orientation == .portrait) ||
                    (UIDevice.current.userInterfaceIdiom == .phone &&
                        orientationInfo.orientation == .landscape &&
                    !isFreshLaunch) {
                    isFreshLaunch = false
                    return
                }
#endif
                selectedMantra = mantra
                if isFreshLaunch { isFreshLaunch = false }
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
#endif
            ToolbarItem {
                Menu {
                    Picker(selection: $sorting, label: Text("Sorting options")) {
                        Label("Alphabetically", systemImage: "textformat").tag(Sorting.title)
                        Label("By readings count", systemImage: "textformat.123").tag(Sorting.reads)
                    }
                }
                label: {
                    Label("Sorting", systemImage: "line.horizontal.3.decrease.circle")
                }
            }
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
            newMantra.uuid = UUID()
            newMantra.reads = Int32.random(in: 0...100_000)
            newMantra.title = "Some Mantra"
            newMantra.text = "Some Text"
            newMantra.details = "Some Details"
            saveContext()
        }
    }
    
    private func saveContext() {
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
    
    static var previews: some View {
        NavigationView {
            MantraListColumn(selectedMantra: .constant(nil))
                .environment(\.managedObjectContext, controller.container.viewContext)
                .environmentObject(OrientationInfo())
        }
    }
}


