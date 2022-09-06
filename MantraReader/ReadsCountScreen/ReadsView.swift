//
//  ReadsView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 17.06.2022.
//

import SwiftUI

struct ReadsView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject var actionService: ActionService
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("isFirstLaunchOfMantraCounterMode") private var isFirstLaunchOfMantraCounterMode = true
    @EnvironmentObject private var dataManager: DataManager
    @ObservedObject private var viewModel: ReadsViewModel
    private var circularViewModel: CircularProgressViewModel
    private var goalButtonViewModel: GoalButtonViewModel
    private let lightHapticGenerator = UIImpactFeedbackGenerator(style: .light)
    
    @State private var isPresentedStatisticsSheet = false
    @State private var isPresentedAdjustingAlert = false
    @State private var isPresentedValidNumberAlert = false
    @State private var adjustingType: AdjustingType?
    @State private var adjustingText: String = ""
    @State private var isPresentedInfoView = false
    @State private var isPresentedUndoAlert = false
    @State private var isPresentedMantraCounterModeAlert = false
    @State private var isPresentedDeleteConfirmation = false
    @Binding private var isMantraCounterMode: Bool
    @Binding private var selectedMantra: Mantra?
    @State private var showBlink = false
    @State private var showHint = false
    @State private var congratulations: Int = 0
    
    init(viewModel: ReadsViewModel, isMantraCounterMode: Binding<Bool>, selectedMantra: Binding<Mantra?>) {
        self.viewModel = viewModel
        self._isMantraCounterMode = isMantraCounterMode
        self._selectedMantra = selectedMantra
        circularViewModel = CircularProgressViewModel(viewModel.mantra)
        goalButtonViewModel = GoalButtonViewModel(viewModel.mantra)
    }
    
    var body: some View {
        let layout = verticalSizeClass == .compact ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())
        
        ZStack {
            GeometryReader { geometry in
                VStack {
                    layout {
                        Spacer()
                        Image(uiImage: viewModel.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .accessibilityIgnoresInvertColors()
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
                                .foregroundStyle(Color.accentColor.gradient)
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
                                .foregroundStyle(Color.accentColor.gradient)
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
                                .foregroundStyle(Color.accentColor.gradient)
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
                    .padding(
                        .bottom,
                        (horizontalSizeClass == .compact && verticalSizeClass == .regular) ||
                        (horizontalSizeClass == .regular && verticalSizeClass == .regular) ? 10 : 0
                    )
                    .alert(
                        viewModel.adjustingAlertTitle(for: adjustingType),
                        isPresented: $isPresentedAdjustingAlert,
                        presenting: adjustingType
                    ) { _ in
                        TextField("Enter number", text: $adjustingText)
                            .onSubmit {
                                validateAndHandleAdjusting()
                            }
                            .keyboardType(.numberPad)
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
        .navigationTitle(verticalSizeClass == .compact ? viewModel.mantra.title ?? "" : "")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.keyboard)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentedUndoAlert = true
                } label: {
                    Image(systemName: "arrow.uturn.backward")
                        .symbolVariant(.circle)
                }
                .disabled(viewModel.undoHistory.isEmpty || isMantraCounterMode)
                .alert(
                    "Undo Changes",
                    isPresented: $isPresentedUndoAlert
                ) {
                    Button("Yes") {
                        viewModel.handleUndo()
                    }
                    Button("No", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to undo the last change?")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        isPresentedStatisticsSheet = true
                    } label: {
                        Label("Readings Statistics", systemImage: "chart.bar")
                    }
                    Button {
                        isPresentedInfoView = true
                    } label: {
                        Label("Detailed Info", systemImage: "info.circle")
                    }
                    Button {
                        viewModel.toggleFavorite()
                    } label: {
                        Label(viewModel.favoriteBarTitle, systemImage: viewModel.favoriteBarImage)
                    }
                    Button(role: .destructive) {
                        isPresentedDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Label("Menu", systemImage: "ellipsis.circle")
                }
                .disabled(isMantraCounterMode)
            }
            .confirmationDialog(
                "Delete Mantra",
                isPresented: $isPresentedDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    withAnimation {
                        selectedMantra = nil
                        dataManager.delete(viewModel.mantra)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this mantra?")
            }
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
        .sheet(isPresented: $isPresentedStatisticsSheet) {
            StatisticsView(viewModel: StatisticsViewModel(mantra: viewModel.mantra, dataManager: dataManager))
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
        .onShake {
            isPresentedUndoAlert = true
        }
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active:
                guard let action = actionService.action else { return }
                isPresentedStatisticsSheet = false
                isPresentedValidNumberAlert = false
                isPresentedInfoView = false
                isPresentedUndoAlert = false
                isPresentedDeleteConfirmation = false
                isPresentedMantraCounterModeAlert = false
                isPresentedAdjustingAlert = false
                adjustingType = nil
                adjustingText = ""
                viewModel.isPresentedCongratulations = false
            default:
                break
            }
        }
        .onDisappear {
            if isMantraCounterMode {
                withAnimation {
                    isMantraCounterMode = false
                }
                UIApplication.shared.isIdleTimerDisabled = false
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
            lightHapticGenerator.impactOccurred()
            UIApplication.shared.isIdleTimerDisabled = true
            showHint = true
            afterDelay(1.5) { showHint = false }
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
