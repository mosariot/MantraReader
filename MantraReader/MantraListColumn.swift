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
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    @AppStorage("sorting") private var sorting: Sorting = .title
    
    @FetchRequest(sortDescriptors: [], animation: .default) private var mantras: FetchedResults<Mantra>
    @State private var isPresentingPresetMantraView = false
    @Binding var selectedMantra: Mantra?
    
#if os(iOS)
    @EnvironmentObject var orientationInfo: OrientationInfo
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    private var isLandscape: Bool { orientationInfo.orientation == .landscape }
#endif
    
    init(selectedMantra: Binding<Mantra?>, sorting: Sorting) {
        _selectedMantra = selectedMantra
        sort(with: sorting)
    }
    
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
                if (isPad || (isPhone && isLandscape)) && isFreshLaunch {
                    selectedMantra = mantra
                    isFreshLaunch = false
                }
#elseif os(macOS)
                if isFreshLaunch {
                    selectedMantra = mantra
                    isFreshLaunch = false
                }
#endif
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
                } label: {
                    Label("Sorting", systemImage: "line.horizontal.3.decrease.circle")
                }
            }
            ToolbarItem {
                Menu {
                    Button(action: addItem) {
                        Label("New Mantra", systemImage: "square.and.pencil")
                    }
                    Button {
                        isPresentingPresetMantraView = true
                    } label: {
                        Label("Preset Mantra", systemImage: "books.vertical")
                    }
                } label: {
                    Label("Adding", systemImage: "plus")
                }
            }
        }
        .onChange(of: sorting) { newValue in sort(with: newValue) }
        .navigationTitle("Mantra Reader")
    }
    
    private func sort(with: Sorting) {
        switch sorting {
                case .title: mantras.sortDescriptors = [SortDescriptor(\Mantra.title, order: .forward)]
                case .reads: mantras.sortDescriptors = [SortDescriptor(\Mantra.reads, order: .forward)]
            }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { mantras[$0] }.forEach {
                if $0 === selectedMantra {
                    selectedMantra = nil
                }
                viewContext.delete($0)
            }
            saveContext()
        }
    }
    
    private func addItem() {
        withAnimation {
            let newMantra = Mantra(context: viewContext)
            newMantra.uuid = UUID()
            newMantra.isFavorite = Bool.random()
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
