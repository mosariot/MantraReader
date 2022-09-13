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
    @AppStorage("ringColor", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter")) private var ringColor: RingColor = .red
    @AppStorage("colorScheme") private var colorScheme: MantraColorScheme = .system
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Mantras sorting", selection: $sorting) {
                    Label("Alphabetically", systemImage: "abc")
                        .tag(Sorting.title)
                    Label("By readings count", systemImage: "text.book.closed")
                        .tag(Sorting.reads)
                }
                .pickerStyle(.inline)
                Picker("Appearance", selection: $colorScheme) {
                    Label {
                        Text("System")
                    } icon: {
                        Text("\(Image(systemName: "lightbulb"))/\(Image(systemName: "lightbulb.slash"))")
                    }
                    .tag(MantraColorScheme.system)
                    Label("Light", systemImage: "lightbulb")
                        .tag(MantraColorScheme.light)
                    Label("Dark", systemImage: "lightbulb.slash")
                        .tag(MantraColorScheme.dark)
                }
                .pickerStyle(.inline)
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
                                gradient: Gradient(colors: RingColor.yellow.colors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 25)
                        .tag(RingColor.yellow)
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
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: RingColor.green.colors),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(radius: 10.0, corners: [.topLeft, .bottomLeft])
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: RingColor.yellow.colors),
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
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        CloseButtonImage()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct CloseButtonImage: View {
    var body: some View {
        Image(systemName: "xmark")
            .symbolVariant(.circle.fill)
            .foregroundColor(.gray.opacity(0.6))
            .scaleEffect(1.2)
    }
}
