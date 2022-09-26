//
//  MantraListColumn.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 21.06.2022.
//

import SwiftUI
import Combine
import MessageUI

struct MantraListColumn: View {
    @Environment(\.isSearching) private var isSearching
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var dataManager: DataManager
    @EnvironmentObject private var actionService: ActionService
    @EnvironmentObject private var settings: Settings
    
    @State private var isPresentedPreloadedMantraList = false
    @State private var isPresentedNewMantraSheet = false
    @State private var isPresentedStatisticsSheet = false
    @State private var isPresentedMantraInfoView = false
    @State private var isPresentedMantraStatisticsSheet = false
    @State private var isPresentedSettingsSheet = false
    @State private var isPresentedFeedbackView = false
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
                                        Label("Reading Statistics", systemImage: "chart.bar")
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
        .animation(.default, value: settings.sorting)
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
                        Label("Reading Statistics", systemImage: "chart.bar")
                    }
                    Button {
                        isPresentedSettingsSheet = true
                       } label: {
                        Label("Settings", systemImage: "slider.horizontal.3")
                    }
                    Section {
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
                    } header: {
                        Label("Add New", systemImage: "plus")
                    }
                    Section {
                        Button {
                            isPresentedFeedbackView = true
                        } label: {
                            Label("Mail Feedback", systemImage: "envelope")
                        }
                        .disabled(!MFMailComposeViewController.canSendMail())
                        Button {
                            guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1557599095?action=write-review") else { return }
                            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                        } label: {
                            Label("App Store Review", systemImage: "highlighter")
                        }
                    } header: {
                        Label("Feedback", systemImage: "ellipsis.bubble")
                    }
                } label: {
                    Label("Menu", systemImage: "ellipsis.circle")
                }
            }
        }
        // Workaround to force a row to see contextMantra
        .onChange(of: contextMantra) { _ in return }
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
            .presentationDetents([.medium])
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
        }
        .sheet(isPresented: $isPresentedFeedbackView) {
            FeedbackView(to: "mosariot@gmail.com", subject: "Mantra Reader Feedback")
        }
        .onChange(of: scenePhase) { newValue in
            guard let action = actionService.action else { return }
            if isSearching, case .openMantra(id: _) = action {
                dismissSearch()
            }
            switch newValue {
            case .active:
                performActionIfNeeded(for: action)
            default:
                break
            }
        }
    }
    
    private func performActionIfNeeded(for action: Action) {
        mantrasForDeletion = nil
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
    }
}
