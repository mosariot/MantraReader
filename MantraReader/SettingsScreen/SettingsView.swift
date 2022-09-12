//
//  SettingsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 11.09.2022.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("sorting") private var sorting: Sorting = .title
    @AppStorage("ringColor") private var ringColor: RingColor = .red
    @AppStorage("colorScheme") private var colorScheme: MantraColorScheme = .system
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Mantras sorting", selection: $sorting) {
                    Text("Alphabetically")
                        .tag(Sorting.title)
                    Text("By readings count")
                        .tag(Sorting.reads)
                }
                Picker("Appearance", selection: $colorScheme) {
                    Text("System")
                        .tag(MantraColorScheme.system)
                    Text("Light")
                        .tag(MantraColorScheme.light)
                    Text("Dark")
                        .tag(MantraColorScheme.dark)
                }
                Picker("Progress ring color", selection: $ringColor) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: RingColor.red.colors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 25)
                        .tag(RingColor.red)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: RingColor.green.colors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 25)
                        .tag(RingColor.green)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: RingColor.blue.colors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 25)
                        .tag(RingColor.blue)
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: RingColor.blue.colors),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(radius: 10.0, corners: [.topLeft, .bottomLeft])
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: RingColor.green.colors),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: RingColor.red.colors),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(radius: 10.0, corners: [.topRight, .bottomRight])
                    }
                    .frame(height: 25)
                    .tag(RingColor.dynamic)
                }
                .pickerStyle(.inline)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .symbolVariant(.circle.fill)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
