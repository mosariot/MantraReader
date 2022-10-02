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
    
    var body: some View {
        VStack {
            Text("\(Int32(value.rounded(.towardZero)))")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .focusable()
                .digitalCrownRotation(
                    $value,
                    from: 0.0,
                    through: adjustingType == .reads ? 10_000.0 : (Float(2_000_001 - viewModel.mantra.reads) / 108.0).rounded(.down),
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
                        .bold()
                }
                .buttonStyle(.borderedProminent)
                .tint(adjustingType == .reads ? nil : Color(#colorLiteral(red: 0.134, green: 0.134, blue: 0.139, alpha: 1)))
                .foregroundColor(adjustingType == .reads ? .black : .secondary.opacity(0.7))
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
                        .bold()
                }
                .buttonStyle(.borderedProminent)
                .tint(adjustingType == .rounds ? nil : Color(#colorLiteral(red: 0.134, green: 0.134, blue: 0.139, alpha: 1)))
                .foregroundColor(adjustingType == .rounds ? .black : .secondary.opacity(0.7))
                .clipShape(Capsule())
            }
            Button("Add") {
                if Int32(value.rounded(.towardZero)) > 0 {
                    viewModel.handleAdjusting(for: adjustingType, with: Int32(value.rounded(.towardZero)))
                }
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
