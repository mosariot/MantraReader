//
//  ReadsView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI

struct ReadsView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("isFirstLaunchOfMantraCounterMode") private var isFirstLaunchOfMantraCounterMode = true
    @ObservedObject private var viewModel: ReadsViewModel
    private var circularViewModel: CircularProgressViewModel
    private var goalButtonViewModel: GoalButtonViewModel
    private let lightHapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    @State private var isPresentedAdjustingAlert = false
    @State private var adjustingType: AdjustingType?
    @State private var adjustingText: String = ""
    @State private var isPresentedDetailsSheet = false
    @State private var isPresentedUndoAlert = false
    @State private var isPresentedMantraCounterModeAlert = false
    @Binding private var isMantraCounterMode: Bool
    @State private var showBlink = false
    @State private var showHint = false
    @State private var congratulations: Int = 0
    
    init(viewModel: ReadsViewModel, isMantraCounterMode: Binding<Bool>) {
        self.viewModel = viewModel
        self._isMantraCounterMode = isMantraCounterMode
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
                                isMantraCounterMode: isMantraCounterMode,
                                frame: circularProgressViewSize(with: geometry.size)
                            )
                            .frame(
                                width: circularProgressViewSize(with: geometry.size),
                                height: circularProgressViewSize(with: geometry.size)
                            )
                            .padding(.bottom, 10)
                            .confettiCannon(
                                counter: $viewModel.confettiTrigger,
                                num: 200,
                                rainHeight: 1000,
                                openingAngle: Angle(degrees: 30),
                                closingAngle: Angle(degrees: 180),
                                radius: 400
                            )
                            GoalButtonView(
                                viewModel: goalButtonViewModel,
                                adjustingType: $adjustingType,
                                isPresentedAdjustingAlert: $isPresentedAdjustingAlert
                            )
                            .disabled(isMantraCounterMode)
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
                        .disabled(isMantraCounterMode)
                        .padding(.horizontal)
                        Button {
                            adjustingType = .rounds
                            isPresentedAdjustingAlert = true
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 60))
                                .symbolVariant(.circle.fill)
                        }
                        .disabled(isMantraCounterMode)
                        .padding(.horizontal)
                        Button {
                            adjustingType = .value
                            isPresentedAdjustingAlert = true
                        } label: {
                            Image(systemName: "hand.draw")
                                .font(.system(size: 60))
                                .symbolVariant(.fill)
                        }
                        .disabled(isMantraCounterMode)
                        .padding(.horizontal)
                    }
                    .padding(
                        .bottom,
                        (horizontalSizeClass == .compact && verticalSizeClass == .regular) ? 10 : 0
                    )
                    .alert(
                        viewModel.adjustingAlertTitle(for: adjustingType),
                        isPresented: $isPresentedAdjustingAlert,
                        presenting: adjustingType
                    ) { _ in
                        TextField("Enter number", text: $adjustingText)
#if os(iOS)
                           .keyboardType(.numberPad)
#endif
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
                }
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
                .ignoresSafeArea(.keyboard)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
// UIAlerController implementation for Adjusting alert
//            if isPresentedAdjustingAlert {
//                AdjustingAlertView(
//                    isPresented: $isPresentedAdjustingAlert,
//                    adjustingType: $adjustingType,
//                    viewModel: viewModel
//                )
//            }
            if isMantraCounterMode {
                MantraCounterModeOverlayView(
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
        }
        .overlay(alignment: .topTrailing) {
            Button {
                if isFirstLaunchOfMantraCounterMode {
                    isPresentedMantraCounterModeAlert = true
                }
                withAnimation {
                    toggleMantraCounterMode()
                }
                
            } label: {
                Image(systemName: "sun.max")
                    .imageScale(.large)
                    .font(isMantraCounterMode ? .title : .none)
                    .symbolVariant(isMantraCounterMode ? .fill : .none)
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
            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.favoriteBarImage)
            }
            .disabled(isMantraCounterMode)
            Button {
                isPresentedDetailsSheet = true
            } label: {
                Image(systemName: "info")
                    .symbolVariant(.circle)
            }
            .disabled(isMantraCounterMode)
        }
        .alert(
            "'Mantra Counter' Mode",
            isPresented: $isPresentedMantraCounterModeAlert
        ) {
            Button("OK", role: .cancel) {
                isFirstLaunchOfMantraCounterMode = false
            }
        } message: {
            Text("You have entered the 'Mantra Counter' mode. Single tap on the screen will add one reading, double tap will add one round. The screen won’t dim. The edit buttons at the bottom are disabled.")
        }
        .onReceive(viewModel.mantra.objectWillChange) { _ in
            viewModel.objectWillChange.send()
        }
        .onDisappear {
            withAnimation {
                isMantraCounterMode = false
            }
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    private func toggleMantraCounterMode() {
        withAnimation {
            isMantraCounterMode.toggle()
        }
        if isMantraCounterMode {
            lightHapticGenerator.impactOccurred()
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
}

struct ReadsView_Previews: PreviewProvider {
    static var previews: some View {
        ReadsView(
            viewModel: ReadsViewModel(
                PersistenceController.previewMantra,
                viewContext: PersistenceController.preview.container.viewContext
            ),
            isMantraCounterMode: .constant(false)
        )
    }
}
