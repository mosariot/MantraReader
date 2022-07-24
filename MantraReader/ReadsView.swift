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
    @State private var isMantraReaderMode = false
    
    var body: some View {
        let layout = verticalSizeClass == .compact ? AnyLayout(_HStackLayout()) : AnyLayout(_VStackLayout())
        
        ZStack {
            GeometryReader { geometry in
                VStack {
                    layout {
                        Spacer()
                        Image(uiImage: viewModel.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                width: imageSize(with: geometry.size),
                                height: imageSize(with: geometry.size)
                            )
                        if verticalSizeClass == .regular {
                            Spacer()
                            Text(viewModel.title)
                                .font(.system(.largeTitle, weight: .medium))
                                .textSelection(.enabled)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        Spacer()
                        VStack {
                            CircularProgressView(
                                viewModel: CircularProgressViewModel(viewModel.mantra),
                                isMantraReaderMode: isMantraReaderMode,
                                frame: circularProgressViewSize(with: geometry.size)
                            )
                            .frame(
                                width: circularProgressViewSize(with: geometry.size),
                                height: circularProgressViewSize(with: geometry.size)
                            )
                            .padding(.bottom, 10)
                            GoalButtonView(
                                viewModel: GoalButtonViewModel(viewModel.mantra),
                                adjustingType: $adjustingType,
                                isPresentedAdjustingAlert: $isPresentedAdjustingAlert
                            )
                            .disabled(isMantraReaderMode)
                        }
                        Spacer()
                    }
                    HStack(
                        spacing: (horizontalSizeClass == .compact && verticalSizeClass != .compact) ? 10 : 50
                    ) {
                        Button {
                            adjustingType = .reads
                            isPresentedAdjustingAlert = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 60))
                                .symbolVariant(.circle.fill)
                        }
                        .disabled(isMantraReaderMode)
                        .padding(.horizontal)
                        Button {
                            adjustingType = .rounds
                            isPresentedAdjustingAlert = true
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 60))
                                .symbolVariant(.circle.fill)
                        }
                        .disabled(isMantraReaderMode)
                        .padding(.horizontal)
                        Button {
                            adjustingType = .value
                            isPresentedAdjustingAlert = true
                        } label: {
                            Image(systemName: "hand.draw")
                                .font(.system(size: 60))
                                .symbolVariant(.fill)
                        }
                        .disabled(isMantraReaderMode)
                        .padding(.horizontal)
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
            }
#if os(iOS)
            if isPresentedAdjustingAlert {
                UpdatingAlertView(
                    isPresented: $isPresentedAdjustingAlert,
                    adjustingType: $adjustingType,
                    viewModel: viewModel
                )
            }
#endif
            Color.gray.opacity(isMantraReaderMode ? 0.2 : 0)
                .ignoresSafeArea()
                .gesture(
                    TapGesture(count: 2)
                        .onEnded {
                            viewModel.handleAdjusting(for: .rounds, with: 1)
                        }
                        .exclusively(
                            before:
                                TapGesture(count: 1)
                                .onEnded {
                                    viewModel.handleAdjusting(for: .reads, with: 1)
                                }
                        )
                )
        }
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation {
                    isMantraReaderMode.toggle()
                }
            } label: {
                Image(systemName: "sun.max")
                    .imageScale(.large)
                    .symbolVariant(isMantraReaderMode ? .fill : .none)
            }
            .padding(20)
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
            viewModel.objectWillChange.send()
        }
    }
    
    private func imageSize(with frame: CGSize) -> CGFloat? {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular): return CGFloat(0.34 * frame.width)
        case (.compact, .compact): return CGFloat(0.45 * frame.height)
        case (.regular, .compact): return CGFloat(0.48 * frame.height)
        case (.regular, .regular): return CGFloat(0.20 * frame.height)
        default: return nil
        }
    }
    
    private func circularProgressViewSize(with frame: CGSize) -> CGFloat? {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular): return CGFloat(0.55 * frame.width)
        case (.compact, .compact): return CGFloat(0.53 * frame.height)
        case (.regular, .compact): return CGFloat(0.57 * frame.height)
        case (.regular, .regular): return CGFloat(0.35 * frame.height)
        default: return nil
        }
    }
}

struct ReadsView_Previews: PreviewProvider {
    static var previews: some View {
        ReadsView(
            viewModel: ReadsViewModel(
                PersistenceController.previewMantra,
                viewContext: PersistenceController.preview.container.viewContext
            )
        )
    }
}
