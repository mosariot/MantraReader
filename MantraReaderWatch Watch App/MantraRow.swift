//
//  MantraRow.swift
//  MantraReaderWatch Watch App
//
//  Created by Александр Воробьев on 23.09.2022.
//

import SwiftUI

struct MantraRow: View {
    @ObservedObject var mantra: Mantra
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(mantra.title ?? "")
                Text("\(mantra.reads)")
                    .font(.caption)
                    .opacity(0.5)
            }
            Spacer()
            if mantra.reads >= mantra.readsGoal {
                Image(systemName: "checkmark")
                .symbolVariant(.circle.fill)
                    .foregroundColor(.green)
            }
        }
    }
}
