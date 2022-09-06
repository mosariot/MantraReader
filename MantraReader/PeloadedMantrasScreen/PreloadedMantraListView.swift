//
//  PreloadedMantraListView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.07.2022.
//

import SwiftUI
import CoreData

struct PreloadedMantraListView: View {
    @EnvironmentObject var actionService: ActionService
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject private var dataManager: DataManager
    @Binding private var isPresented: Bool
    @StateObject private var viewModel: PreloadedMantraListViewModel
    @State private var successfullyAdded = false
    private let addHapticGenerator = UINotificationFeedbackGenerator()
    
    init(isPresented: Binding<Bool>, dataManager: DataManager) {
        self._isPresented = isPresented
        _viewModel = StateObject(wrappedValue: PreloadedMantraListViewModel(dataManager: dataManager))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                List(viewModel.mantras) { mantra in
                    PreloadedMantraRow(mantra: mantra)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.select(mantra)
                        }
                }
                .listStyle(.plain)
                .navigationTitle("Mantras Choice")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                                .symbolVariant(.circle.fill)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            viewModel.checkForDuplication()
                            if !viewModel.isDuplicating {
                                addMantras()
                            }
                        }
                        .disabled(viewModel.selectedMantrasTitles.isEmpty)
                        .confirmationDialog(
                            "Duplicating Mantras",
                            isPresented: $viewModel.isDuplicating,
                            titleVisibility: .visible
                        ) {
                            Button("Add") {
                                addMantras()
                            }
                        } message: {
                            Text("One of the selected mantras is already in your mantra list. Add anyway?")
                        }
                    }
                }
                if successfullyAdded {
                    CheckMarkView()
                }
            }
            .disabled(successfullyAdded)
            .onChange(of: scenePhase) { newValue in
                switch newValue {
                case .active:
                    guard let action = actionService.action else { return }
                    viewModel.isDuplicating = false
                default:
                    break
                }
            }
        }
    }
    
    private func addMantras() {
        withAnimation {
            addHapticGenerator.notificationOccurred(.success)
            dataManager.addMantras(with: viewModel.selectedMantrasTitles)
            successfullyAdded = true
            afterDelay(0.7) { isPresented = false }
        }
    }
}
