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
                    viewModel.select(mantra)
                }
        }
        .navigationTitle("Mantras Choice")
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
                viewModel.addMantras()
                isPresented = false
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
