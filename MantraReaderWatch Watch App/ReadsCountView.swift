//
//  DetailsColumn.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 23.09.2022.
//

import SwiftUI

struct ReadsCountView: View {
    @ObservedObject var mantra: Mantra
    
    var body: some View {
        VStack {
            Text("\(mantra.title ?? "")")
                .padding(.bottom, 10)
            ProgressRing(progress: Double(mantra.reads) / Double(mantra.readsGoal), thickness: 15)
        }
    }
}
