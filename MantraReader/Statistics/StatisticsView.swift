//
//  StatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 28.08.2022.
//

import SwiftUI

struct StatisticsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Week") {
                    Text("Week Statistics")
                        .frame(height: 150)
                }
                Section("Month") {
                    Text("Month Statistics")
                        .frame(height: 150)
                }
                Section("Year") {
                    Text("Year Statistics")
                        .frame(height: 150)
                }
            }
            .navigationTitle("Overall Statistics")
        }
        
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            StatisticsView()
        }
    }
}
