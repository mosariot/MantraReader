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
    private let addHapticGenerator = UINotificationFeedbackGenerator()
    
    var body: some View {
        NavigationStack {
            List(viewModel.mantras) { mantra in
                PreloadedMantraRow(mantra: mantra)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.select(mantra)
                    }
            }
            .confirmationDialog(
                "Duplicating Mantras",
                isPresented: $viewModel.isDuplicating
            ) {
                Button {
                    addMantras()
                } label: {
                    Text("Add")
                }
            } message: {
                Text("One of the selected mantras is already in your mantra list. Add anyway?")
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
                    Button {
                        viewModel.checkForDuplication()
                        if !viewModel.isDuplicating {
                            addMantras()
                        }
                    } label: {
                        Text("Add")
                    }
                    .disabled(viewModel.selectedMantrasTitles.isEmpty)
                }
            }
        }
    }
    
    private func addMantras() {
        withAnimation {
            viewModel.addMantras()
            addHapticGenerator.notificationOccurred(.success)
            afterDelay(1.7) { isPresented = false }
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
