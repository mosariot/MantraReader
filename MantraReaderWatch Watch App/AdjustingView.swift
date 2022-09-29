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
    private var through: Float {
        switch adjustingType {
        case .reads:
            return 1000
//            Float(1_000_000 - viewModel.mantra.reads)
        case .rounds:
            return 1000
//            Float(1_000_000 - viewModel.mantra.reads) / 108
        default:
            return 0
        }
    }
    
    var body: some View {
        VStack {
            Text("\(value, specifier: "%.0f")")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .focusable()
                .digitalCrownRotation(
                    $value,
                    from: 0.0,
                    through: through,
                    by: 1,
                    sensitivity: .low
            )
            HStack {
                Button {
                    withAnimation {
                        adjustingType = .reads
                        value = 0.0
                    }
                } label: {
                    Text("Reads")
                        .minimumScaleFactor(0.8)
                }
                .foregroundColor(adjustingType == .reads ? .white : .secondary)
                .background(adjustingType == .reads ? Color.accentColor : nil)
                .clipShape(Capsule())
                Button {
                    withAnimation {
                        adjustingType = .rounds
                        value = 0.0
                    }
                } label: {
                    Text("Rounds")
                        .minimumScaleFactor(0.8)
                }
                .foregroundColor(adjustingType == .rounds ? .white : .secondary)
                .background(adjustingType == .rounds ? Color.accentColor : nil)
                .clipShape(Capsule())
            }
            Button("Add") {
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
