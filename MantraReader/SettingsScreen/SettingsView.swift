//
//  SettingsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 11.09.2022.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: Settings
    
    private var preferredColorScheme: UIUserInterfaceStyle {
        switch settings.colorScheme {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Mantras sorting", selection: $settings.sorting) {
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
                Picker("Appearance", selection: $settings.colorScheme) {
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
                Picker("Progress ring color", selection: $settings.ringColor) {
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
            .onChange(of: settings.colorScheme) { _ in
                setPreferredColorScheme()
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onChange(of: settings.ringColor) { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
            .navigationTitle("Settings")
        }
    }
    
    private func setPreferredColorScheme() {
        let scenes = UIApplication.shared.connectedScenes
        guard let scene = scenes.first as? UIWindowScene else { return }
        scene.keyWindow?.overrideUserInterfaceStyle = preferredColorScheme
    }
}
