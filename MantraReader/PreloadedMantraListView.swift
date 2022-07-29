//
//  PreloadedMantraListView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 29.07.2022.
//

import SwiftUI

struct PreloadedMantraListView: View {
    @Binding isPresentedPreloadedMantraList: Bool
    @StateObject var viewModel = PreloadedMantraListViewModel()
    
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
                    isPresentedPreloadedMantra = false
                } label: {
                    Image(systemName: "xmark")
                        .symbolVariant(.circle.fill)
                }
            }
            Button {
                viewModel.addMantras()
            } label: {
                Text("Add")
            }
            .disabled(viewModel.selectedMantras.isEmpty)
        }
    }
}

struct PreloadedMantraListView_Previews: PreviewProvider {
    static var previews: some View {
        PreloadedMantraListView()
    }
}
