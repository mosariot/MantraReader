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
    private var circularViewModel: CircularProgressViewModel
    private var goalButtonViewModel: GoalButtonViewModel
    
    @State private var isPresentedAdjustingAlert = false
    @State private var adjustingType: AdjustingType?
    @State private var adjustingText: String = ""
    @State private var isPresentedDetailsSheet = false
    @State private var isPresentedUndoAlert = false
    @Binding private var isMantraReaderMode: Bool
    @State private var showBlink = false
    @State private var showHint = false
    
    init(viewModel: ReadsViewModel, isMantraReaderMode: Binding<Bool>) {
        self.viewModel = viewModel
        self._isMantraReaderMode = isMantraReaderMode
        circularViewModel = CircularProgressViewModel(viewModel.mantra)
        goalButtonViewModel = GoalButtonViewModel(viewModel.mantra)
    }
    
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
                                .padding(.horizontal)
                        }
                        Spacer()
                        VStack {
                            CircularProgressView(
                                viewModel: circularViewModel,
                                isMantraReaderMode: isMantraReaderMode,
                                frame: circularProgressViewSize(with: geometry.size)
                            )
                            .frame(
                                width: circularProgressViewSize(with: geometry.size),
                                height: circularProgressViewSize(with: geometry.size)
                            )
                            .padding(.bottom, 10)
                            GoalButtonView(
                                viewModel: goalButtonViewModel,
                                adjustingType: $adjustingType,
                                isPresentedAdjustingAlert: $isPresentedAdjustingAlert
                            )
                            .disabled(isMantraReaderMode)
                        }
                        Spacer()
                    }
                    HStack(
                        spacing: (horizontalSizeClass == .compact && verticalSizeClass == .regular) ? 10 : 50
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
                    .padding(
                        .bottom,
                        (horizontalSizeClass == .compact && verticalSizeClass == .regular) ? 10 : 0
                    )
#if os(macOS)
                    .alert(
                        viewModel.adjustingAlertTitle(for: adjustingType),
                        isPresented: $isPresentedAdjustingAlert,
                        presenting: adjustingType
                    ) { _ in
                        TextField("Enter number", text: $adjustingText)
                        Button(viewModel.adjustingAlertActionTitle(for: adjustingType)) {
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
                    .alert(
                        "Congratulations!",
                        isPresented: $viewModel.isPresentedCongratulations,
                        presenting: viewModel.congratulations
                    ) { _ in
                        Button("OK", role: .cancel) {
                            viewModel.congratulations = nil
                        }
                    } message: { congratulation in
                        Text(viewModel.congratulationsAlertMessage(for: congratulation))
                    }
                    .alert(
                        "Undo Changes",
                        isPresented: $isPresentedUndoAlert
                    ) {
                        Button("Yes") {
                            viewModel.handleUndo()
                        }
                        Button("No", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to undo the last change?")
                    }
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
            if isMantraReaderMode {
                MantraReaderModeOverlayView(
                    showBlink: $showBlink,
                    viewModel: viewModel
                )
            }
            if showBlink {
                BlinkView()
            }
            if showHint {
                HintView()
            }
            if viewModel.showConfetti {
                Color.pink.opacity(0.3)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                toggleMantraReaderMode()
            } label: {
                Image(systemName: "sun.max")
                    .imageScale(.large)
                    .symbolVariant(isMantraReaderMode ? .fill : .none)
            }
            .padding(20)
        }
        .navigationTitle(verticalSizeClass == .compact ? viewModel.mantra.title ?? "" : "")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.keyboard)
        .toolbar {
            Button {
                isPresentedUndoAlert = true
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
            .disabled(isMantraReaderMode)
            Button {
                isPresentedDetailsSheet = true
            } label: {
                Image(systemName: "info")
                    .symbolVariant(.circle)
            }
            .disabled(isMantraReaderMode)
        }
        .onReceive(viewModel.mantra.objectWillChange) { _ in
            viewModel.objectWillChange.send()
        }
    }
    
    private func toggleMantraReaderMode() {
        withAnimation {
            isMantraReaderMode.toggle()
        }
        if isMantraReaderMode {
            showHint = true
            afterDelay(1.5) { showHint = false }
            UIApplication.shared.isIdleTimerDisabled = true
        } else {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    private func imageSize(with frame: CGSize) -> CGFloat? {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular): return CGFloat(0.40 * frame.width)
        case (.compact, .compact): return CGFloat(0.50 * frame.height)
        case (.regular, .compact): return CGFloat(0.50 * frame.height)
        case (.regular, .regular): return CGFloat(0.25 * frame.height)
        default: return nil
        }
    }
    
    private func circularProgressViewSize(with frame: CGSize) -> CGFloat? {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular): return CGFloat(0.58 * frame.width)
        case (.compact, .compact): return CGFloat(0.55 * frame.height)
        case (.regular, .compact): return CGFloat(0.55 * frame.height)
        case (.regular, .regular): return CGFloat(0.40 * frame.height)
        default: return nil
        }
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

struct ReadsView_Previews: PreviewProvider {
    static var previews: some View {
        ReadsView(
            viewModel: ReadsViewModel(
                PersistenceController.previewMantra,
                viewContext: PersistenceController.preview.container.viewContext
            ),
            isMantraReaderMode: .constant(false)
        )
    }
}
