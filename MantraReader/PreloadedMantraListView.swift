//
//  PreloadedMantraListView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI

struct PreloadedMantraListView: View {
    @Binding isPresented: Bool
    @StateObject var viewModel: PreloadedMantraListViewModel
    
    var body: some View {
        List(viewModel.mantras) { mantra in
            PreloadedMantraRow(mantra: mantra)
                .onTapGesture {
                    withAnimation {
                        viewModel.select(mantra)
                    }
                }
        }
        .confirmationDialog(
            "Duplicating Mantras",
            isPresented: $viewModel.isDuplicating
        ) {
            Button {
                withAnimation {
                    viewModel.addMantras()
                    afterDelay(1.7) { isPresented = false }
                }
            } label: {
                Text("Add")
            }
        } message: {
            Text("One of the selected mantras is already in your mantra list. Add anyway?")
        }
        .navigationTitle("Mantras Choice")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .symbolVariant(.circle.fill)
                }
            }
            Button {
                withAnimation {
                    viewModel.checkForDuplication($isPresented)
                }
            } label: {
                Text("Add")
            }
            .disabled(viewModel.selectedMantras.isEmpty)
        }
    }
}

struct PreloadedMantraListView_Previews: PreviewProvider {
    static var previews: some View {
        PreloadedMantraListView(
            isPresented: .constant(true),
            viewModel: PreloadedMantraListViewModel(
                viewContext: PersistentController.preview.container.viewContext
            )
        )
    }
}
