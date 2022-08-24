//
//  ReadsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 17.06.2022.
//

import SwiftUI

struct ReadsView: View {
#if os(iOS)
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
#endif
    @AppStorage("isFirstLaunchOfMantraCounterMode") private var isFirstLaunchOfMantraCounterMode = true
    @EnvironmentObject private var dataManager: DataManager
    @ObservedObject private var viewModel: ReadsViewModel
    private var circularViewModel: CircularProgressViewModel
    private var goalButtonViewModel: GoalButtonViewModel
#if os(iOS)
    private let lightHapticGenerator = UIImpactFeedbackGenerator(style: .light)
#endif
    
    @State private var isPresentedAdjustingAlert = false
    @State private var isPresentedValidNumberAlert = false
    @State private var adjustingType: AdjustingType?
    @State private var adjustingText: String = ""
    @State private var isPresentedInfoView = false
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
#if os(iOS)
        let layout = verticalSizeClass == .compact ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())
#elseif os(macOS)
        let layout = AnyLayout(VStackLayout())
#endif
        
        ZStack {
            GeometryReader { geometry in
                VStack {
                    layout {
                        Spacer()
#if os(iOS)
                        Image(uiImage: viewModel.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .accessibilityIgnoresInvertColors()
                            .frame(
                                width: imageSize(with: geometry.size),
                                height: imageSize(with: geometry.size)
                            )
#elseif os(macOS)
                        Image(nsImage: viewModel.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .accessibilityIgnoresInvertColors()
                            .frame(
                                width: imageSize(with: geometry.size),
                                height: imageSize(with: geometry.size)
                            )
#endif
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
                    .animation(.default, value: verticalSizeClass)
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
                        .alert("Please enter a valid number", isPresented: $isPresentedValidNumberAlert) {
                            Button("OK") {
                                adjustingText = ""
                                isPresentedAdjustingAlert = true
                            }
                        }
                    }
#if os(iOS)
                    .padding(
                        .bottom,
                        (horizontalSizeClass == .compact && verticalSizeClass == .regular) ||
                        (horizontalSizeClass == .regular && verticalSizeClass == .regular) ? 10 : 0
                    )
#elseif os(macOS)
                    .padding(.bottom, 10)
#endif
                    .alert(
                        viewModel.adjustingAlertTitle(for: adjustingType),
                        isPresented: $isPresentedAdjustingAlert,
                        presenting: adjustingType
                    ) { _ in
                        TextField("Enter number", text: $adjustingText)
                            .onSubmit {
                                validateAndHandleAdjusting()
                            }
#if os(iOS)
                            .keyboardType(.numberPad)
#endif
                        Button(viewModel.adjustingAlertActionTitle(for: adjustingType)) {
                            validateAndHandleAdjusting()
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
                } else {
                    withAnimation {
                        toggleMantraCounterMode()
                    }
                }
            } label: {
                Image(systemName: "sun.max")
                    .imageScale(.large)
                    .symbolVariant(isMantraCounterMode ? .circle.fill : .none)
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                    .padding(.leading, 25)
                    .padding(.bottom, 25)
            }
            .controlSize(.large)
            .contentShape(Rectangle())
        }
#if os(iOS)
        .navigationTitle(verticalSizeClass == .compact ? viewModel.mantra.title ?? "" : "")
#endif
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
                isPresentedInfoView = true
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
                withAnimation {
                    toggleMantraCounterMode()
                }
            }
        } message: {
            Text("You are entering the 'Mantra Counter' mode. Single tap on the screen will add one reading, double tap will add one round. The screen won’t dim. The edit buttons at the bottom are disabled.")
        }
        .sheet(isPresented: $isPresentedInfoView) {
            InfoView(
                viewModel: InfoViewModel(viewModel.mantra, dataManager: dataManager),
                infoMode: .view,
                isPresented: $isPresentedInfoView
            )
        }
        .onReceive(viewModel.mantra.objectWillChange) { _ in
            viewModel.objectWillChange.send()
        }
#if os(iOS)
        .onShake {
            isPresentedUndoAlert = true
        }
#endif
        .onDisappear {
            if isMantraCounterMode {
                withAnimation {
                    isMantraCounterMode = false
                }
#if os(iOS)
                UIApplication.shared.isIdleTimerDisabled = false
#endif
            }
        }
    }
    
    private func validateAndHandleAdjusting() {
        if viewModel.isValidUpdatingNumber(for: adjustingText, adjustingType: adjustingType) {
            guard let alertNumber = Int32(adjustingText) else { return }
            viewModel.handleAdjusting(for: adjustingType, with: alertNumber)
            adjustingType = nil
            adjustingText = ""
        } else {
            isPresentedValidNumberAlert = true
        }
    }
    
    private func toggleMantraCounterMode() {
        withAnimation {
            isMantraCounterMode.toggle()
        }
        if isMantraCounterMode {
#if os(iOS)
            lightHapticGenerator.impactOccurred()
            UIApplication.shared.isIdleTimerDisabled = true
#endif
            showHint = true
            afterDelay(1.5) { showHint = false }
        } else {
#if os(iOS)
            UIApplication.shared.isIdleTimerDisabled = false
#endif
        }
    }
    
    private func imageSize(with frame: CGSize) -> CGFloat? {
#if os(iOS)
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular): return CGFloat(0.40 * frame.width)
        case (.compact, .compact): return CGFloat(0.50 * frame.height)
        case (.regular, .compact): return CGFloat(0.50 * frame.height)
        case (.regular, .regular): return CGFloat(0.25 * frame.height)
        default: return nil
        }
#elseif os(macOS)
        return CGFloat(0.25 * frame.height)
#endif
    }
    
    private func circularProgressViewSize(with frame: CGSize) -> CGFloat? {
#if os(iOS)
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular): return CGFloat(0.58 * frame.width)
        case (.compact, .compact): return CGFloat(0.55 * frame.height)
        case (.regular, .compact): return CGFloat(0.55 * frame.height)
        case (.regular, .regular): return CGFloat(0.40 * frame.height)
        default: return nil
        }
#elseif os(macOS)
        return CGFloat(0.40 * frame.height)
#endif
    }
}
