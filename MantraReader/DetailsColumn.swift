//
//  DetailsColumn.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI

struct DetailsColumn: View {
    @Environment(\.managedObjectContext) private var viewContext
    var selectedMantra: Mantra?
    @State var isMantraCounterMode: Bool = false
    
    var body: some View {
        if let selectedMantra {
            ReadsView(
                viewModel: ReadsViewModel(selectedMantra, viewContext: viewContext),
                isMantraCounterMode: $isMantraReaderMode
            )
            .onChange(of: selectedMantra) { _ in
                withAnimation {
                    isMantraCounterMode = false
                }
                UIApplication.shared.isIdleTimerDisabled = false
            }
        } else {
            Text("Select a mantra")
                .foregroundColor(.gray)
        }
    }
}

struct DetailsView_Previews: PreviewProvider {    
    static var previews: some View {
        DetailsColumn(selectedMantra: PersistenceController.previewMantra)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
