//
//  SettingsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 11.09.2022.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("sorting") private var sorting: Sorting = .title
    @AppStorage("ringColor", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var ringColor: RingColor = .red
    @AppStorage("colorScheme", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    private var colorScheme: MantraColorScheme = .system
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Mantras sorting", selection: $sorting) {
                    Label {
                        Text("Alphabetically")
                    } icon: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(.blue.gradient)
                                .frame(width: 30, height: 30)
                            Image(systemName: "abc")
                                .foregroundColor(.white)
                                .imageScale(.small)
                        }
                    }
                    .tag(Sorting.title)
                    Label {
                        Text("By readings count")
                    } icon: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(.pink.gradient)
                                .frame(width: 30, height: 30)
                            Image(systemName: "text.book.closed")
                                .foregroundColor(.white)
                        }
                    }
                    .tag(Sorting.reads)
                }
                .pickerStyle(.inline)
                Picker("Appearance", selection: $colorScheme) {
                    Label {
                        Text("System")
                    } icon: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(.green.gradient)
                                .frame(width: 30, height: 30)
                            Image(systemName: "lightbulb.2")
                                .foregroundColor(.white)
                        }
                    }
                    .tag(MantraColorScheme.system)
                    Label {
                        Text("Light")
                    } icon: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(.yellow.gradient)
                                .frame(width: 30, height: 30)
                            Image(systemName: "lightbulb")
                                .foregroundColor(.white)
                        }
                    }
                    .tag(MantraColorScheme.light)
                    Label {
                        Text("Dark")
                    } icon: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(.gray.gradient)
                                .frame(width: 30, height: 30)
                            Image(systemName: "lightbulb.slash")
                                .foregroundColor(.white)
                        }
                    }
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
            .onChange(of: colorScheme) { newValue in
                WidgetCenter.shared.reloadAllTimelines()
            }
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
