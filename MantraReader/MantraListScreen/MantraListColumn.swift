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
    @Environment(\.dismissSearch) var dismissSearch
    @EnvironmentObject private var dataManager: DataManager
    @EnvironmentObject var actionService: ActionService
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("sorting") private var sorting: Sorting = .title
    
    @State private var isPresentedPreloadedMantraList = false
    @State private var isPresentedNewMantraSheet = false
    @State private var isPresentedStatisticsSheet = false
    @State private var isPresentedMantraInfoView = false
    @State private var isPresentedMantraStatisticsSheet = false
    @State private var isPresentedSettingsSheet = false
    @State private var isDeletingMantras = false
    @State private var mantrasForDeletion: [Mantra]?
    @State private var contextMantra: Mantra?
    
    var mantras: SectionedFetchResults<Bool, Mantra>
    @Binding var selectedMantra: Mantra?
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
                                        contextMantra = mantra
                                        isPresentedMantraStatisticsSheet = true
                                    } label: {
                                        Label("Readings Statistics", systemImage: "chart.bar")
                                    }
                                    Button {
                                        contextMantra = mantra
                                        isPresentedMantraInfoView = true
                                    } label: {
                                        Label("Detailed Info", systemImage: "info.circle")
                                    }
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
                Button {
                    isPresentedSettingsSheet = true
                } label: {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    isPresentedStatisticsSheet = true
                } label: {
                    Label("Readings Statistics", systemImage: "chart.bar")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
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
            }
        }
        .onChange(of: contextMantra) { _ in return }
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
        .sheet(isPresented: $isPresentedMantraStatisticsSheet) {
            StatisticsView(viewModel: StatisticsViewModel(mantra: contextMantra, dataManager: dataManager))
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
        .sheet(isPresented: $isPresentedMantraInfoView) {
            InfoView(
                viewModel: InfoViewModel(contextMantra!, dataManager: dataManager),
                infoMode: .view,
                isPresented: $isPresentedMantraInfoView
            )
        }
        .sheet(isPresented: $isPresentedSettingsSheet) {
           SettingsView()
               .presentationDetents([.medium])
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
        mantrasForDeletion = nil
        dismissSearch()
        let rootViewController = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter({ $0.isKeyWindow }).first?.rootViewController
        rootViewController?.dismiss(animated: true) {
            switch action {
            case .newMantra:
                isPresentedNewMantraSheet = true
            case .showStatistics:
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
        
        switch action {
        case .newMantra:
            afterDelay(0.8) { isPresentedNewMantraSheet = true }
        case .showStatistics:
            afterDelay(0.8) { isPresentedStatisticsSheet = true }
        case .openMantra(let id):
            mantras.forEach { section in
                section.forEach { mantra in
                    if mantra.uuid == UUID(uuidString: "\(id)") {
                        afterDelay(0.8) { selectedMantra = mantra }
                    }
                }
            }
        }
        actionService.action = nil
    }
}
