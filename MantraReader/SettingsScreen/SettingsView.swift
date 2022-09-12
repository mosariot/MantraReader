//
//  SettingsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 11.09.2022.
//

import SwiftUI

enum ColorScheme: String, Hashable, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: String { self.rawValue }
}

enum RingColor: String, Hashable {
    case red
    case green
    case blue
    case dynamic
}

struct SettingsView: View {
    @AppStorage("sorting") private var sorting: Sorting = .title
    @AppStorage("ringColor") private var ringColor: RingColor = .red
    @AppStorage("colorScheme") private var colorScheme: ColorScheme = .system
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Mantras sorting", selection: $sorting) {
                    Text("Alphabetically")
                        .tag(Sorting.title)
                    Text("By readings count")
                        .tag(Sorting.reads)
                }
                Picker("Ring color", selection: $ringColor) {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(Constants.progressStartColor), Color(Constants.progressEndColor)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(maxWidth: 200)
                        .tag(RingColor.red)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.green)
                        .frame(maxWidth: 200)
                        .tag(RingColor.green)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.blue)
                        .frame(maxWidth: 200)
                        .tag(RingColor.blue)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.gray)
                        .frame(maxWidth: 200)
                        .tag(RingColor.dynamic)
                }
                Picker("Appearance", selection: $colorScheme) {
                    ForEach(ColorScheme.allCases) { scheme in
                        Text(scheme.rawValue.capitalized)
                            .tag(scheme)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
