//
//  SettingsView.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 24.09.2022.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: Settings
    var mantras: SectionedFetchResults<Bool, Mantra>
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Mantras sorting", selection: $settings.sorting) {
                    Label {
                        Text("Alphabetically")
                            .lineLimit(1)
                    } icon: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(.blue.gradient)
                                .frame(width: 30, height: 30)
                            Image(systemName: "abc")
                                .foregroundColor(.white)
                                .imageScale(.small)
                        }
                        .padding(.trailing, 5)
                    }
                    .tag(Sorting.title)
                    Label {
                        Text("By readings count")
                            .lineLimit(1)
                    } icon: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 7)
                                .fill(.pink.gradient)
                                .frame(width: 30, height: 30)
                            Image(systemName: "text.book.closed")
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 5)
                    }
                    .tag(Sorting.reads)
                }
                .pickerStyle(.inline)
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
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        CloseButtonImage()
                    }
                }
            }
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
        }
    }
}
