//
//  PreloadedMantraListView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 29.07.2022.
//

import SwiftUI
import CoreData

struct PreloadedMantraListView: View {
    @Binding private var isPresented: Bool
    @StateObject private var viewModel: PreloadedMantraListViewModel
    @State private var successfullyAdded = false
#if os(iOS)
    private let addHapticGenerator = UINotificationFeedbackGenerator()
#endif
    
    init(isPresented: Binding<Bool>, viewContext: NSManagedObjectContext) {
        self._isPresented = isPresented
        _viewModel = StateObject(wrappedValue: PreloadedMantraListViewModel(viewContext: viewContext))
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
        }
    }
    
    private func addMantras() {
        withAnimation {
#if os(iOS)
            addHapticGenerator.notificationOccurred(.success)
#endif
            viewModel.addMantras()
            successfullyAdded = true
            afterDelay(0.7) { isPresented = false }
        }
    }
}

//struct PreloadedMantraListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PreloadedMantraListView(
//            isPresented: .constant(true),
//            viewContext: PersistenceController.preview.container.viewContext)
//    }
//}
