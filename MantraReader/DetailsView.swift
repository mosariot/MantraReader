//
//  DetailsView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI

struct DetailsView: View {
    var selectedMantra: Mantra?
    
    var body: some View {
        ZStack {
            if let selectedMantra {
                ReadsView(viewModel: ReadsViewModel(selectedMantra))
            } else {
                Text("Select a mantra")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView()
    }
}
