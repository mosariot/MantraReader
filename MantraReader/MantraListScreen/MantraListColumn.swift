//
//  MantraListColumn.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI
import Combine

struct MantraListColumn: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.isSearching) private var isSearching: Bool
    
    @State private var searchText = ""
    @State private var isPresentedPreloadedMantraList = false
    @State private var isPresentedNewMantraSheet = false
    @State private var isDeletingMantras = false
    @State private var mantrasForDeletion: [Mantra]?
    
    var mantras: SectionedFetchResults<Bool, Mantra>
    @Binding var selectedMantra: Mantra?
    @Binding var sorting: Sorting
    
    private let widgetManager = MantraWidgetManager()
    
    var body: some View {
        ZStack {
            List(mantras, selection: $selectedMantra) { section in
                Section(section.id ? "Favorites" : "Mantras") {
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
            if isSearching && mantras.isEmpty {
                VStack {
                    Spacer()
                        .frame(height: 50)
                    Text("No matches found")
                    Spacer()
                }
            }
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
        .listStyle(.sidebar)
        .refreshable {
            viewContext.refreshAllObjects()
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
#endif
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Picker("", selection: $sorting) {
                        Label("Alphabetically", systemImage: "textformat").tag(Sorting.title)
                        Label("By readings count", systemImage: "textformat.123").tag(Sorting.reads)
                    }
                } label: {
                    Label("Sorting", systemImage: "line.horizontal.3.decrease.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        isPresentedNewMantraSheet = true
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
            widgetManager.updateWidgetData(viewContext: viewContext)
        }
        .sheet(isPresented: $isPresentedPreloadedMantraList) {
            PreloadedMantraListView(
                isPresented: $isPresentedPreloadedMantraList,
                viewContext: viewContext
            )
        }
        .sheet(isPresented: $isPresentedNewMantraSheet) {
            InfoView(
                viewModel: InfoViewModel(Mantra(context: viewContext), viewContext: viewContext),
                infoMode: .addNew,
                isPresented: $isPresentedNewMantraSheet
            )
        }
    }
    
    private func saveContext() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
            widgetManager.updateWidgetData(viewContext: viewContext)
        } catch {
            fatalCoreDataError(error)
        }
    }
}

//struct MantraListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            MantraListColumn(
//                mantras: mantras,
//                selectedMantra: .constant(nil)
//            )
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//        }
//    }
//}
