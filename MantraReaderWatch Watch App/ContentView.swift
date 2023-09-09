//
//  ContentView.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 20.09.2022.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var dataManager: DataManager
    @AppStorage("sorting", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    var sorting: Sorting = .title
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    
    @State private var selectedMantra: [Mantra] = []
    @State private var isPresentedStatisticsSheet = false
    @State private var isPresentedSettingsSheet = false
    @State private var isDeletingMantras = false
    @State private var mantrasForDeletion: [Mantra]?
    
    @SectionedFetchRequest(sectionIdentifier: \.isFavorite, sortDescriptors: [])
    private var mantras: SectionedFetchResults<Bool, Mantra>
    
    init() {
        var currentSortDescriptor: SortDescriptor<Mantra>
        switch sorting {
        case .title: currentSortDescriptor = SortDescriptor(\.title, order: .forward)
        case .reads: currentSortDescriptor = SortDescriptor(\.reads, order: .reverse)
        }
        self._mantras = SectionedFetchRequest(
            sectionIdentifier: \.isFavorite,
            sortDescriptors: [
                SortDescriptor(\.isFavorite, order: .reverse),
                currentSortDescriptor
            ],
            predicate: NSPredicate(format: "title != %@", ""),
            animation: .default
        )
    }
    
    var body: some View {
        NavigationStack(path: $selectedMantra) {
            ZStack {
                List(mantras) { section in
                    Section(section.id ? "Favorites" : "Mantras") {
                        ForEach(section) { mantra in
                            NavigationLink(value: mantra) {
                                MantraRow(mantra: mantra)
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
                    }
                }
                .navigationDestination(for: Mantra.self) { mantra in
                    if #available(watchOS 10, *) {
                        ReadsViewWatch10(viewModel: ReadsViewModel(mantra, dataManager: dataManager))
                    } else {
                        ReadsView(viewModel: ReadsViewModel(mantra, dataManager: dataManager))
                    }                }
                if isFirstLaunch {
                    ProgressView("Syncing...")
                }
                if !isFirstLaunch && mantras.count == 0 {
                    Text("Please add some mantras on your iPhone or iPad")
                        .foregroundColor(.secondary)
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
            .sheet(isPresented: $isPresentedSettingsSheet) {
                SettingsView(mantras: mantras)
            }
            .sheet(isPresented: $isPresentedStatisticsSheet) {
                if #available(watchOS 10, *) {
                    StatisticsViewWatch10(viewModel: StatisticsViewModel(dataManager: dataManager))
                } else {
                    StatisticsView(viewModel: StatisticsViewModel(dataManager: dataManager))
                }
            }
            .toolbar {
                ToolbarItemGroup {
                    HStack {
                        Button {
                            isPresentedStatisticsSheet = true
                        } label: {
                            Image(systemName: "chart.bar")
                                .imageScale(.large)
                        }
                        Button {
                            isPresentedSettingsSheet = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .imageScale(.large)
                        }
                    }
                }
            }
            .onReceive(mantras.publisher.count()) { count in
                if isFirstLaunch && count > 0 {
                    isFirstLaunch = false
                }
                var isMantraExist = false
                mantras.forEach { section in
                    section.forEach { mantra in
                        if selectedMantra.count > 0, mantra == selectedMantra[0] {
                            isMantraExist = true
                        }
                    }
                }
                if !isMantraExist {
                    selectedMantra = []
                }
            }
            .onAppear {
                dataManager.deleteEmptyMantrasIfNeeded()
            }
            .onOpenURL { url in
                mantras.forEach { section in
                    section.forEach { mantra in
                        if mantra.uuid == UUID(uuidString: "\(url)") {
                            selectedMantra = [mantra]
                        }
                    }
                }
            }
            .onChange(of: scenePhase) { newValue in
                if newValue == .active {
                    dataManager.saveData()
                }
            }
        }
    }
}
