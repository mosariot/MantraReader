//
//  AdjustingView.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 26.09.2022.
//

import SwiftUI

struct AdjustingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var value: Float = 0.0
    @State private var adjustingType: AdjustingType = .reads
    
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
                    through: 10_000,
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
                .foregroundColor(adjustingType == .reads ? .white : .secondary)
                .background(adjustingType == .reads ? Color.accentColor.opacity(0.9) : nil)
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
                .foregroundColor(adjustingType == .rounds ? .white : .secondary)
                .background(adjustingType == .rounds ? Color.accentColor.opacity(0.9) : nil)
                .clipShape(Capsule())
            }
            Button("Add") {
                previousReads = viewModel.mantra.reads
                viewModel.handleAdjusting(for: adjustingType, with: Int32(value.rounded(.towardZero)))
                dismiss()
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
    }
}
