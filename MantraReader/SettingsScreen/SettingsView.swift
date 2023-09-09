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
#if os(watchOS)
    var mantras: SectionedFetchResults<Bool, Mantra>
#endif
    
#if os(iOS)
    private var preferredColorScheme: UIUserInterfaceStyle {
        switch settings.colorScheme {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }
#endif
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Mantras sorting", selection: $settings.sorting) {
                    Label {
                        Text("Alphabetically")
#if os(watchOS)
                            .lineLimit(1)
#endif
                    } icon: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(.blue.gradient)
                                .frame(width: 30, height: 30)
                            Image(systemName: "abc")
                                .foregroundColor(.white)
                                .imageScale(.small)
                        }
#if os(watchOS)
                        .padding(.trailing, 5)
#endif
                    }
                    .tag(Sorting.title)
                    Label {
                        Text("By readings count")
#if os(watchOS)
                            .lineLimit(1)
#endif
                    } icon: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(.pink.gradient)
                                .frame(width: 30, height: 30)
                            Image(systemName: "text.book.closed")
                                .foregroundColor(.white)
                        }
#if os(watchOS)
                        .padding(.trailing, 5)
#endif
                    }
                    .tag(Sorting.reads)
                }
                .pickerStyle(.inline)
#if os(iOS)
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
#endif
                Picker("Progress ring color", selection: $settings.ringColor) {
                    HStack(spacing: 5) {
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
                    HStack(spacing: 5) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: RingColor.red.colors),
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
                                    gradient: Gradient(colors: RingColor.green.colors),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(radius: 10.0, corners: [.topRight, .bottomRight])
                    }
                    .frame(height: 25)
                    .tag(RingColor.dynamicReverse)
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
            .navigationTitle("Settings")
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        CloseButtonImage()
                    }
                }
#elseif os(watchOS)
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        if #available(watchOS 10, *) {
                            Image(systemName: "xmark")
                                .foregroundColor(.gray.opacity(0.6))
                        } else {
                            CloseButtonImage()
                        }
                    }
                }
#endif
            }
#if os(watchOS)
            .onChange(of: settings.sorting) {
                switch $0 {
                case .title: mantras.sortDescriptors = [
                    SortDescriptor(\.isFavorite, order: .reverse),
                    SortDescriptor(\.title, order: .forward)
                ]
                case .reads: mantras.sortDescriptors = [
                    SortDescriptor(\.isFavorite, order: .reverse),
                    SortDescriptor(\.reads, order: .reverse)
                ]
                }
            }
#elseif os(iOS)
            .onChange(of: settings.colorScheme) { _ in
                setPreferredColorScheme()
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onChange(of: settings.ringColor) { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
#endif
        }
    }
    
#if os(iOS)
    private func setPreferredColorScheme() {
        let scenes = UIApplication.shared.connectedScenes
        guard let scene = scenes.first as? UIWindowScene else { return }
        scene.keyWindow?.overrideUserInterfaceStyle = preferredColorScheme
    }
#endif
}
