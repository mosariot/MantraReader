//
//  PreloadedMantraListView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI

struct PreloadedMantraListView: View {
    @Binding var isPresented: Bool
    @StateObject var viewModel: PreloadedMantraListViewModel
    @State private var successfullyAdded = false
    private let addHapticGenerator = UINotificationFeedbackGenerator()
    
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
                                .symbolVariant(.circle.fill)
                                .foregroundColor(.gray)
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
                    ZStack {
                        CheckMarkView()
                        Color.gray.opacity(0.01)
                    }
                }
            }
        }
    }
    
    private func addMantras() {
        withAnimation {
            viewModel.addMantras()
            addHapticGenerator.notificationOccurred(.success)
            successfullyAdded = true
            afterDelay(0.9) { isPresented = false }
        }
    }
}

struct PreloadedMantraListView_Previews: PreviewProvider {
    static var previews: some View {
        PreloadedMantraListView(
            isPresented: .constant(true),
            viewModel: PreloadedMantraListViewModel(
                viewContext: PersistenceController.preview.container.viewContext
            )
        )
    }
}
