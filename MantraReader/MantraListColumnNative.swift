//
//  MantraListColumn.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI
import CoreData
import Combine

//enum Sorting: String, Codable {
//    case title
//    case reads
//}

struct MantraListColumnNative: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @AppStorage("sorting") private var sorting: Sorting = .title
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    @SectionedFetchRequest(
        sectionIdentifier: \.isFavorite,
        sortDescriptors: [
            SortDescriptor(\.isFavorite, order: .reverse),
            SortDescriptor(\.title, order: .forward)
        ],
        animation: .default
    )
    private var mantras: SectionedFetchResults<Bool, Mantra>
    @Binding var selectedMantra: Mantra?
    @State private var searchText = ""
    @State private var isPresentedPreloadedMantraList = false
    
    var body: some View {
        List(mantras, selection: $selectedMantra) { section in
            Section(section.id ? "Favorites" : "Other Mantras") {
                ForEach(section) { mantra in
                    NavigationLink(value: mantra) {
                        MantraRow(mantra: mantra, isSelected: mantra === selectedMantra)
                            .contextMenu {
                                Button {
                                    withAnimation { mantra.isFavorite.toggle() }
                                    saveContext()
                                } label: {
                                    Label(
                                        mantra.isFavorite ? "Unfavorite" : "Favorite",
                                        systemImage: mantra.isFavorite ? "star.slash" : "star"
                                    )
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
                            withAnimation { delete(mantra) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            withAnimation { mantra.isFavorite.toggle() }
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
                    delete(for: indexSet, in: section)
                }
            }
            .headerProminence(.increased)
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
        .onAppear {
            if !mantras.isEmpty {
#if os(iOS)
                if (verticalSizeClass == .regular && horizontalSizeClass == .regular)
                    || (verticalSizeClass == .compact && horizontalSizeClass == .regular)
                    && isFreshLaunch {
                    selectedMantra = mantras[0][0]
                    isFreshLaunch = false
                }
#elseif os(macOS)
                if isFreshLaunch {
                    selectedMantra = mantras[0][0]
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
                    Button(action: addItem) {
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
    
    private func delete(_ mantra: Mantra) {
        withAnimation {
            if mantra === selectedMantra { selectedMantra = nil }
            viewContext.delete(mantra)
            saveContext()
        }
    }
    
    private func delete(
        for indexSet: IndexSet,
        in section: SectionedFetchResults<Bool, Mantra>.Element
    ) {
        withAnimation {
            indexSet.map { section[$0] }.forEach {
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

struct MantraListViewNative_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    
    static var previews: some View {
        NavigationView {
            MantraListColumn(selectedMantra: .constant(nil))
                .environment(\.managedObjectContext, controller.container.viewContext)
                .environmentObject(OrientationInfo())
        }
    }
}
