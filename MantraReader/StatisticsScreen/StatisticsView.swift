//
//  StatisticsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 28.08.2022.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var dataManager: DataManager
    @Binding var isPresented: Bool
    var mantra: Mantra?
    
    var body: some View {
        NavigationStack {
            List {
                Section("Week") {
                    Text("Week Statistics")
                        .foregroundColor(.secondary)
                        .frame(height: 150)
                }
                Section("Month") {
                    Text("Month Statistics")
                        .foregroundColor(.secondary)
                        .frame(height: 150)
                }
                Section("Year") {
                    Text("Year Statistics")
                        .foregroundColor(.secondary)
                        .frame(height: 150)
                }
            }
            .navigationTitle(mantra?.title ?? String(localized: "Overall Statistics"))
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
            }
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            StatisticsView(isPresented: .constant(true))
        }
    }
}
