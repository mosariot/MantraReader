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
    @SceneStorage("sorting") private var sorting: Sorting = .title
    @SceneStorage("isFreshLaunch") private var isFreshLaunch = true
    @FetchRequest(sortDescriptors: [], animation: .default) private var mantras: FetchedResults<Mantra>
    @Binding var selectedMantra: Mantra?
    @State private var searchText = ""
    @State private var isPresentingPresetMantraView = false
    
    private var sortedMantras: [Mantra] {
        switch sorting {
        case .title: return mantras.sorted { $0.title! < $1.title! }
        case .reads: return mantras.sorted { $0.reads > $1.reads }
        }
    }
    
    private var sortedSearchedMantras: [Mantra] {
        searchText.isEmpty ? sortedMantras : sortedMantras.filter { $0.title!.contains(searchText) }
    }
    
    private var favoriteMantras: [Mantra] {
        sortedSearchedMantras.filter { $0.isFavorite }
    }
    
    private var otherMantras: [Mantra] {
        sortedSearchedMantras.filter { !$0.isFavorite }
    }
    
#if os(iOS)
    @EnvironmentObject var orientationInfo: OrientationInfo
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    private var isLandscape: Bool { orientationInfo.orientation == .landscape }
#endif
    
    var body: some View {
        List(selection: $selectedMantra) {
            Section(header: Text("Favorites")) {
                ForEach(favoriteMantras) { mantra in
                    NavigationLink(value: mantra) {
                        MantraRow(mantra: mantra, isSelected: mantra === selectedMantra)
                            .contextMenu {
                                Button {
                                    withAnimation { mantra.isFavorite.toggle() }
                                    saveContext()
                                } label: {
                                    Label("Unfavorite", systemImage: "star.slash")
                                }
                                Button(role: .destructive) {
                                    delete(mantra)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            delete(mantra)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            withAnimation { mantra.isFavorite.toggle() }
                            saveContext()
                        } label: {
                            Label("Favorite", systemImage: "star.slash")
                        }
                        .tint(.indigo)
                    }
                }
                .onDelete { indexSet in
                    delete(in: favoriteMantras, with: indexSet)
                }
            }
            .headerProminence(.increased)
            
            Section(header: Text("Other Mantras")) {
                ForEach(otherMantras) { mantra in
                    NavigationLink(value: mantra) {
                        MantraRow(mantra: mantra, isSelected: mantra === selectedMantra)
                            .contextMenu {
                                Button {
                                    withAnimation { mantra.isFavorite.toggle() }
                                    saveContext()
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                Button(role: .destructive) {
                                    delete(mantra)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            delete(mantra)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            withAnimation { mantra.isFavorite.toggle() }
                            saveContext()
                        } label: {
                            Label("Favorite", systemImage: "star")
                        }
                        .tint(.indigo)
                    }
                }
                .onDelete { indexSet in
                    delete(in: favoriteMantras, with: indexSet)
                }
            }
            .headerProminence(.increased)
        }
        .animation(.default, value: sorting)
        .animation(.default, value: searchText)
        .searchable(text: $searchText, prompt: "Search")
        .listStyle(.insetGrouped)
        .onAppear {
            if let mantra = favoriteMantras.first {
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
//        .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange) {
//            viewContext.refreshAllObjects()
//        }
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
        .navigationTitle("Mantra Reader")
    }
    
    private func delete(_ mantra: Mantra) {
        withAnimation {
            if mantra === selectedMantra { selectedMantra = nil }
            viewContext.delete(mantra)
            saveContext()
        }
    }
    
    private func delete(in mantras: [Mantra], with offsets: IndexSet) {
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
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            fatalCoreDataError(error)
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
