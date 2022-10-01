//
//  AdjustingView.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 26.09.2022.
//

import SwiftUI

struct AdjustingView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isFirstAppearOfAdjustingView") private var isFirstAppearOfAdjustingView = true
    @State private var value: Float = 0.0
    @State private var adjustingType: AdjustingType = .reads
    @State private var isPresentedFirstAppearOfAdjustingViewAlert = false
    
    var viewModel: ReadsViewModel
    @Binding var previousReads: Int32
    
    var body: some View {
        VStack {
            Text("\(value, specifier: "%.0f")")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .focusable()
                .digitalCrownRotation(
                    $value,
                    from: 0.0,
                    through: adjustingType == .reads ? 10_000.0 : Float(2_000_001 - viewModel.mantra.reads) / 108.0,
                    by: 1,
                    sensitivity: .medium
            )
            HStack {
                Button {
                    guard adjustingType != .reads else { return }
                    withAnimation {
                        adjustingType = .reads
                        value = 0.0
                    }
                } label: {
                    Text("Reads")
                        .minimumScaleFactor(0.8)
                }
                .buttonStyle(.borderedProminent)
                .tint(adjustingType == .reads ? nil : Color.gray.opacity(0.3))
                .foregroundColor(adjustingType == .reads ? nil : .secondary)
                .clipShape(Capsule())
                Button {
                    guard adjustingType != .rounds else { return }
                    withAnimation {
                        adjustingType = .rounds
                        value = 0.0
                    }
                } label: {
                    Text("Rounds")
                        .minimumScaleFactor(0.8)
                }
                .buttonStyle(.borderedProminent)
                .tint(adjustingType == .rounds ? nil : Color.gray.opacity(0.3))
                .foregroundColor(adjustingType == .rounds ? nil : .secondary)
                .clipShape(Capsule())
            }
            Button("Add") {
                previousReads = viewModel.mantra.reads
                viewModel.handleAdjusting(for: adjustingType, with: Int32(value.rounded(.towardZero)))
                dismiss()
            }
            .alert("", isPresented: $isPresentedFirstAppearOfAdjustingViewAlert) {
                Button("OK") { }
            } message: {
                Text("For change the value just spin the Digital Crown")
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.accentColor)
            }
        }
        .onAppear {
            if isFirstAppearOfAdjustingView {
                isFirstAppearOfAdjustingView = false
                isPresentedFirstAppearOfAdjustingViewAlert = true
            }
        }
    }
}
