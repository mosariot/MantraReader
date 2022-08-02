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
    @AppStorage("sorting") private var sorting: Sorting = .title
    
    @State private var searchText = ""
    @State private var isPresentedPreloadedMantraList = false
    @State private var isDeletingMantras = false
    @State private var mantrasForDeletion: [Mantra]?
    
    var mantras: SectionedFetchResults<Bool, Mantra>
    @Binding var selectedMantra: Mantra?
    
    var body: some View {
        List(mantras, selection: $selectedMantra) { section in
            Section(section.id ? "Favorites" : "Other Mantras") {
                ForEach(section) { mantra in
                    NavigationLink(value: mantra) {
                        MantraRow(mantra: mantra, isSelected: mantra === selectedMantra)
                            .contextMenu {
                                Button {
                                    withAnimation {
                                        mantra.isFavorite.toggle()
                                    }
                                    saveContext()
                                } label: {
                                    Label(
                                        mantra.isFavorite ? "Unfavorite" : "Favorite",
                                        systemImage: mantra.isFavorite ? "star.slash" : "star"
                                    )
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
                            Label(
                                mantra.isFavorite ? "Unfavorite" : "Favorite",
                                systemImage: mantra.isFavorite ? "star.slash" : "star"
                            )
                        }
                        .tint(.indigo)
                    }
                }
                .onDelete { indexSet in
                    mantrasForDeletion = nil
                    indexSet.map { section[$0] }.forEach {
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
        .onChange(of: searchText) {
            mantras.nsPredicate = $0.isEmpty ? nil : NSPredicate(format: "title contains[cd] %@", $0)
        }
        .onChange(of: sorting) {
            switch $0 {
            case .title: mantras.sortDescriptors = [
                SortDescriptor(\.isFavorite, order: .reverse),
                SortDescriptor(\.title, order: .forward)
            ]
            case .reads: mantras.sortDescriptors = [
                SortDescriptor(\.isFavorite, order: .reverse),
                SortDescriptor(\.reads, order: .reverse)
            ]
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            viewContext.refreshAllObjects()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)) { _ in
            viewContext.refreshAllObjects()
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
                        withAnimation {
                            addItem()
                        }
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
            PreloadedMantraListView(isPresented: $isPresentedPreloadedMantraList)
        }
    }
    
    private func addItem() {
        let newMantra = Mantra(context: viewContext)
        newMantra.uuid = UUID()
        newMantra.isFavorite = Bool.random()
        newMantra.reads = Int32.random(in: 0...100_000)
        newMantra.title = "Some Mantra"
        newMantra.text = "Some Text"
        newMantra.details = "Some Details"
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
            MantraListColumn(
                SectionedFetchRequest(
                    sectionIdentifier: \.isFavorite,
                    sortDescriptors: [
                        SortDescriptor(\.isFavorite, order: .reverse),
                        SortDescriptor(\.title, order: .forward)
                    ],
                    animation: .default
                ),
                selectedMantra: .constant(nil)
            )
            .environment(\.managedObjectContext, controller.container.viewContext)
        }
    }
}
