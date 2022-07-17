//
//  ReadsView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI

struct ReadsView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var viewModel: ReadsViewModel
    @State private var isPresentedAdjustingAlert = false
    @State private var adjustingType: AdjustingType?
    @State private var adjustingText: String = ""
    @State private var isPresentedDetailsSheet = false
    
#if os(iOS)
    private var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
#endif
    
    var body: some View {
        let layout = (verticalSizeClass == .compact && isPhone) ?
        AnyLayout(_HStackLayout()) :
        AnyLayout(_VStackLayout())
        
        ZStack {
            GeometryReader { geo in
                VStack {
                    layout {
                        Spacer()
                        Image(uiImage: viewModel.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        // wChR
//                            .frame(width: 0.35 * geo.size.width)
                        // wChC
//                            .frame(height: 0.45 * geo.size.height)
                        // wRhC
                            .frame(height: 0.48 * geo.size.height)
                        // wRhR
//                            .frame(height: 0.2 * geo.size.height)
                            .layoutPriority(1)
                        if verticalSizeClass == .regular {
                            Spacer()
                            Text(viewModel.title)
                                .font(.system(.largeTitle, weight: .medium))
                                .textSelection(.enabled)
                                .padding()
                        }
                        Spacer()
                        VStack {
                            CircularProgressView(
                                progress: viewModel.progress,
                                displayedNumber: viewModel.displayedReads,
                                isAnimated: viewModel.isAnimated
                            )
                            // wChR
//                            .frame(width: 0.58 * geo.size.width)
                            // wChC
//                            .frame(height: 0.53 * geo.size.height)
                            // wRhC
                            .frame(height: 0.57 * geo.size.height)
                            // wRhR
//                            .frame(height: 0.35 * geo.size.height)
                            .padding()
                            Button("Current goal: \(viewModel.displayedGoal, specifier: "%.0f")") {
                                adjustingType = .goal
                                isPresentedAdjustingAlert = true
                            }
                        }
                        Spacer()
                    }
                    HStack(
                        spacing: (horizontalSizeClass == .compact
                                  && !(verticalSizeClass == .compact && isPhone)) ? 10 : 50
                    ) {
                        Button {
                            adjustingType = .reads
                            isPresentedAdjustingAlert = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 60))
                                .symbolVariant(.circle.fill)
                        }
                        .padding()
                        Button {
                            adjustingType = .rounds
                            isPresentedAdjustingAlert = true
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 60))
                                .symbolVariant(.circle.fill)
                        }
                        .padding()
                        Button {
                            adjustingType = .value
                            isPresentedAdjustingAlert = true
                        } label: {
                            Image(systemName: "hand.draw")
                                .font(.system(size: 60))
                                .symbolVariant(.fill)
                        }
                        .padding()
                    }
#if os(macOS)
                    .alert(
                        viewModel.alertTitle(for: adjustingType),
                        isPresented: $isPresentedAdjustingAlert,
                        presenting: adjustingType
                    ) { _ in
                        TextField("Enter number", text: $adjustingText)
                        Button(viewModel.alertActionTitle(for: adjustingType)) {
                            if viewModel.isValidUpdatingNumber(for: adjustingText, adjustingType: adjustingType) {
                                guard let alertNumber = Int32(adjustingText) else { return }
                                viewModel.handleAdjusting(for: adjustingType, with: alertNumber)
                            }
                            adjustingType = nil
                            adjustingText = ""
                        }
                        Button("Cancel", role: .cancel) {
                            adjustingType = nil
                            adjustingText = ""
                        }
                    }
#endif
                }
                .ignoresSafeArea(.keyboard)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
#if os(iOS)
                if isPresentedAdjustingAlert {
                    UpdatingAlertView(
                        isPresented: $isPresentedAdjustingAlert,
                        adjustingType: $adjustingType,
                        viewModel: viewModel
                    )
                }
#endif
            }
            .ignoresSafeArea(.keyboard)
            .toolbar {
                Button {
                    viewModel.handleUndo()
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .symbolVariant(.circle)
                }
                .disabled(viewModel.undoHistory.isEmpty)
                Button {
                    viewModel.toggleFavorite()
                } label: {
                    Image(systemName: viewModel.favoriteBarImage)
                }
                Button {
                    isPresentedDetailsSheet = true
                } label: {
                    Image(systemName: "info")
                        .symbolVariant(.circle)
                }
            }
            .onReceive(viewModel.mantra.objectWillChange) { _ in
                viewModel.updateForMantraChanges()
            }
        }
    }
}

import CoreData

struct ReadsView_Previews: PreviewProvider {
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
        ReadsView(
            viewModel: ReadsViewModel(
                previewMantra(viewContext: controller.container.viewContext),
                viewContext: controller.container.viewContext
            )
        )
    }
}
