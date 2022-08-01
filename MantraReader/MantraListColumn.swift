//
//  MantraListColumn.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI
import Combine

enum Sorting: String, Codable {
    case title
    case reads
}

struct MantraListColumn: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @AppStorage("sorting") private var sorting: Sorting = .title
    @SceneStorage("isFreshLaunch") private var isFreshLaunch = true
    @FetchRequest(sortDescriptors: [], animation: .default) private var mantras: FetchedResults<Mantra>
    @Binding var selectedMantra: Mantra?
    @State private var searchText = ""
    @State private var isPresentedPreloadedMantraList = false
    @State private var isDeletingMantras = false
    @State private var mantrasForDeletion: [Mantra]?
    
    private var sortedMantras: [Mantra] {
        let mantrasWithTitle = mantras.filter { $0.title != "" }
        switch sorting {
        case .title: return mantrasWithTitle.sorted(using: KeyPathComparator(\.title))
        case .reads: return mantrasWithTitle.sorted(using: KeyPathComparator(\.reads, order: .reverse))
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
    
    var body: some View {
        List(selection: $selectedMantra) {
            Section(header: Text("Favorites")) {
                ForEach(favoriteMantras) { mantra in
                    NavigationLink(value: mantra) {
                        MantraRow(mantra: mantra, isSelected: mantra === selectedMantra)
                            .contextMenu {
                                Button {
                                    withAnimation {
                                        mantra.isFavorite.toggle()
                                    }
                                    saveContext()
                                } label: {
                                    Label("Unfavorite", systemImage: "star.slash")
                                }
                                Button(role: .destructive) {
                                    mantrasForDeletion = [mantra]
                                    isDeletingMantras = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button {
                            mantrasForDeletion = [mantra]
                            isDeletingMantras = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                        Button {
                            withAnimation {
                                mantra.isFavorite.toggle()
                            }
                            saveContext()
                        } label: {
                            Label("Unfavorite", systemImage: "star.slash")
                        }
                        .tint(.indigo)
                    }
                }
                .onDelete { indexSet in
                    mantrasForDeletion = nil
                    indexSet.map { favoriteMantras[$0] }.forEach {
                        mantrasForDeletion?.append($0)
                    }
                    isDeletingMantras = true
                }
            }
            .headerProminence(.increased)
            
            Section(header: Text("Other Mantras")) {
                ForEach(otherMantras) { mantra in
                    NavigationLink(value: mantra) {
                        MantraRow(mantra: mantra, isSelected: mantra === selectedMantra)
                            .contextMenu {
                                Button {
                                    withAnimation {
                                        mantra.isFavorite.toggle()
                                    }
                                    saveContext()
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                Button(role: .destructive) {
                                    mantrasForDeletion = [mantra]
                                    isDeletingMantras = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button {
                            mantrasForDeletion = [mantra]
                            isDeletingMantras = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                        Button {
                            withAnimation {
                                mantra.isFavorite.toggle()
                            }
                            saveContext()
                        } label: {
                            Label("Favorite", systemImage: "star")
                        }
                        .tint(.indigo)
                    }
                }
                .onDelete { indexSet in
                    mantrasForDeletion = nil
                    indexSet.map { otherMantras[$0] }.forEach {
                        mantrasForDeletion?.append($0)
                    }
                    isDeletingMantras = true
                }
            }
            .headerProminence(.increased)
        }
        .confirmationDialog(
            "Delete Mantra",
            isPresented: $isDeletingMantras,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation {
                    mantrasForDeletion!.forEach {
                        if $0 === selectedMantra {
                            selectedMantra = nil
                        }
                        viewContext.delete($0)
                    }
                }
                saveContext()
                mantrasForDeletion = nil
            }
            Button("Cancel", role: .cancel) {
                mantrasForDeletion = nil
            }
        } message: {
            Text("Are you sure you want to delete this mantra?")
        }
        .navigationTitle("Mantra Reader")
        .animation(.default, value: sorting)
        .animation(.default, value: searchText)
        .searchable(text: $searchText, prompt: "Search")
        .listStyle(.insetGrouped)
        .onAppear {
            var mantraToSelect: Mantra? = nil
            if let candidate = otherMantras.first {
                mantraToSelect = candidate
            }
            if let candidate = favoriteMantras.first {
                mantraToSelect = candidate
            }
            if let mantraToSelect {
#if os(iOS)
                if ((verticalSizeClass == .regular && horizontalSizeClass == .regular)
                    || (verticalSizeClass == .compact && horizontalSizeClass == .regular))
                    && isFreshLaunch {
                    selectedMantra = mantraToSelect
                    isFreshLaunch = false
                }
#elseif os(macOS)
                if isFreshLaunch {
                    selectedMantra = mantraToSelect
                    isFreshLaunch = false
                }
#endif
            }
        }
        .refreshable(action: {
            viewContext.refreshAllObjects()
        })
        .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)) { _ in
//            viewContext.refreshAllObjects()
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
                    Button {
                        addItem()
                    } label: {
                        Label("New Mantra", systemImage: "square.and.pencil")
                    }
                    Button {
                        isPresentedPreloadedMantraList = true
                    } label: {
                        Label("Preset Mantra", systemImage: "books.vertical")
                    }
                } label: {
                    Label("Adding", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentedPreloadedMantraList) {
            PreloadedMantraListView(
                isPresented: $isPresentedPreloadedMantraList,
                viewModel: PreloadedMantraListViewModel(viewContext: viewContext)
            )
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
        }
        saveContext()
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
