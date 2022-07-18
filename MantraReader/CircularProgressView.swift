//
//  CircularProgressView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI

struct CircularProgressView: View {
    @StateObject var viewModel: CircularProgressViewModel
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(
                        .gray.opacity(0.5),
                        lineWidth: 20
                    )
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(
                        strokeColor(for: viewModel.progress),
                        style: StrokeStyle(
                            lineWidth: 20,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        viewModel.isAnimated ?
                            Animation.easeOut(duration: Constants.animationTime) :
                            Animation.linear(duration: 0.01),
                        value: viewModel.progress
                    )
                Text("\(viewModel.displayedReads, specifier: "%.0f")")
                    .font(.system(.largeTitle, design: .rounded, weight: .medium))
                    .textSelection(.enabled)
                    .bold()
                    .dynamicTypeSize(.medium)
            }
        }
        .onReceive(viewModel.mantra.objectWillChange) { _ in
            viewModel.updateForMantraChanges()
        }
    }
    
    private func strokeColor(for progress: Double) -> Color {
        switch progress {
        case ..<0.5: return .green
        case 0.5..<1.0: return .orange
        case 1.0...: return .pink
        default: return .green
        }
    }
}

import CoreData

struct CircularProgressView_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    static func previewMantra(viewContext: NSManagedObjectContext) -> Mantra {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try mantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return mantras[Int.random(in: 0...mantras.count-1)]
    }
    
    static var previews: some View {
        CircularProgressView(
            viewModel: CircularProgressViewModel(
                previewMantra(viewContext: controller.container.viewContext)
            )
        )
        .padding()
        .previewDisplayName("Circular Progress View")
    }
}
