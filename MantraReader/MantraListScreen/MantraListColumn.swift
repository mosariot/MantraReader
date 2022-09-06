//
//  MantraListColumn.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 21.06.2022.
//

import SwiftUI
import Combine

struct MantraListColumn: View {
    @Environment(\.isSearching) private var isSearching: Bool
    @EnvironmentObject private var dataManager: DataManager
    @EnvironmentObject var actionService: ActionService
    @Environment(\.scenePhase) var scenePhase
    
    @State private var isPresentedPreloadedMantraList = false
    @State private var isPresentedNewMantraSheet = false
    @State private var isPresentedStatisticsSheet = false
    @State private var isDeletingMantras = false
    @State private var mantrasForDeletion: [Mantra]?
    
    var mantras: SectionedFetchResults<Bool, Mantra>
    @Binding var selectedMantra: Mantra?
    @Binding var sorting: Sorting
    @Binding var searchText: String
    
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
                                        dataManager.saveData()
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
                                dataManager.saveData()
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
                        .foregroundColor(.secondary)
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
                        dataManager.delete($0)
                    }
                }
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
        .listStyle(.sidebar)
        .refreshable {
            dataManager.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        isPresentedStatisticsSheet = true
                    } label: {
                        Label("Readings Statistics", systemImage: "chart.bar")
                    }
                    Menu {
                        Picker("Sorting", selection: $sorting) {
                            Label("Alphabetically", systemImage: "textformat").tag(Sorting.title)
                            Label("By readings count", systemImage: "textformat.123").tag(Sorting.reads)
                        }
                    } label: {
                        Label("Sorting", systemImage: "line.horizontal.3.decrease.circle")
                    }
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
                        Label("Add New", systemImage: "plus")
                    }
                } label: {
                    Label("Menu", systemImage: "ellipsis.circle")
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
            dataManager.saveData()
        }
        .sheet(isPresented: $isPresentedStatisticsSheet) {
            StatisticsView(viewModel: StatisticsViewModel(dataManager: dataManager))
        }
        .sheet(isPresented: $isPresentedPreloadedMantraList) {
            PreloadedMantraListView(
                isPresented: $isPresentedPreloadedMantraList,
                dataManager: dataManager
            )
        }
        .sheet(isPresented: $isPresentedNewMantraSheet) {
            InfoView(
                viewModel: InfoViewModel(Mantra(context: dataManager.viewContext), dataManager: dataManager),
                infoMode: .addNew,
                isPresented: $isPresentedNewMantraSheet
            )
        }
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active:
                performActionIfNeeded()
            default:
                break
            }
        }
    }
    
    private func performActionIfNeeded() {
        guard let action = actionService.action else { return }
        isPresentedPreloadedMantraList = false
        isDeletingMantras = false
        
        afterDelay(0.3) {
            switch action {
            case .newMantra:
                isPresentedStatisticsSheet = false
                isPresentedNewMantraSheet = true
            case .showStatistics:
                isPresentedNewMantraSheet = false
                isPresentedStatisticsSheet = true
            case .openMantra(let id):
                mantras.forEach { section in
                    section.forEach { mantra in
                        if mantra.uuid == UUID(uuidString: "\(id)") {
                            selectedMantra = mantra
                        }
                    }
                }
            }
            actionService.action = nil
        }
    }
}
