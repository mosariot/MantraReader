//
//  ReadsViewWatch10.swift
//  MantraReaderWatch Watch App
//
//  Created by Александр Воробьев on 10.06.2023.
//

import SwiftUI

@available(watchOS 10, *)
struct ReadsViewWatch10: View {
    @AppStorage("isFirstLaunchOfMantraCounterMode") private var isFirstLaunchOfMantraCounterMode = true
    @EnvironmentObject private var dataManager: DataManager
    @StateObject var viewModel: ReadsViewModel
    
    @State private var isPresentedStatisticsSheet = false
    @State private var isPresentedInfoSheet = false
    @State private var isPresentedInfoAlert = false
    @State private var isPresentedMantraCounterModeAlert = false
    @State private var isPresentedMantraCounterModeInfo = false
    @State private var isPresentedAdjustingSheet = false
    @State private var isMantraCounterMode = false
    @State private var showHint = false
    @State private var previousReads: Int32 = 0
    
    var body: some View {
        let longPressGesture = LongPressGesture(minimumDuration: 1)
            .onEnded { _ in
                if isFirstLaunchOfMantraCounterMode {
                    isPresentedMantraCounterModeAlert = true
                } else {
                    withAnimation {
                        toggleMantraCounterMode()
                    }
                }
            }
        
        ZStack {
            CircularProgressView(
                viewModel: CircularProgressViewModel(viewModel.mantra),
                isMantraCounterMode: isMantraCounterMode
            )
            .padding(.top, 5)
            .padding(.bottom, -5)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack {
                        Button {
                            previousReads = viewModel.mantra.reads
                            isPresentedAdjustingSheet = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 37))
                                .symbolVariant(.circle.fill)
                                .foregroundStyle(Color.accentColor.gradient)
                        }
                        .controlSize(.mini)
                        .buttonStyle(.borderless)
                        .disabled(isMantraCounterMode || viewModel.isAboutToShowCongratulations)
                        .padding(.bottom, -10)
                        Spacer()
                        Button {
                            isPresentedInfoAlert = true
                        } label: {
                            Image(systemName: "ellipsis")
                                .symbolVariant(.circle.fill)
                                .font(.system(size: 37))
                                .foregroundStyle(Color.accentColor.gradient)
                        }
                        .controlSize(.mini)
                        .buttonStyle(.borderless)
                        .disabled(isMantraCounterMode || viewModel.isAboutToShowCongratulations)
                        .padding(.bottom, -10)
                        .alert("Select an option", isPresented: $isPresentedInfoAlert) {
                            Button("Detailed Info") {
                                isPresentedInfoSheet = true
                            }
                            Button("Reading Statistics") {
                                isPresentedStatisticsSheet = true
                            }
                            Button("Mantra Counter") {
                                isPresentedMantraCounterModeInfo = true
                            }
                            Button("Dismiss") { }
                        }
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
                    previousReads = viewModel.mantra.reads
                }
            } message: { congratulation in
                Text(viewModel.congratulationsAlertMessage(for: congratulation))
            }
            .confettiCannon(
                counter: $viewModel.confettiTrigger,
                num: 200,
                rainHeight: 450,
                openingAngle: Angle(degrees: 30),
                closingAngle: Angle(degrees: 180),
                radius: 200
            )
            .padding(.horizontal)
            .alert("'Mantra Counter' Mode", isPresented: $isPresentedMantraCounterModeInfo) {
                Button("OK") { }
            } message: {
                Text("Use long press on the screen to enter and quit the mode.")
            }
            if isMantraCounterMode {
                MantraCounterModeOverlayView(viewModel: viewModel)
            }
            if showHint {
                HintView(showHint: $showHint)
            }
        }
        .gesture(longPressGesture)
        .alert(
            "'Mantra Counter' Mode",
            isPresented: $isPresentedMantraCounterModeAlert
        ) {
            Button("OK") {
                isFirstLaunchOfMantraCounterMode = false
                withAnimation {
                    toggleMantraCounterMode()
                }
            }
        } message: {
            Text("You are entering the 'Mantra Counter' mode. Single tap on the screen will add one reading, double tap will add one round. Use 'Always On' mode (or extended Wake Duration if you don't have Always On mode) in your Watch Settings to stay in app while reading your mantras.")
        }
        .sheet(isPresented: $isPresentedAdjustingSheet) {
            AdjustingView(viewModel: viewModel)
        }
        .sheet(isPresented: $isPresentedInfoSheet) {
            InfoView(mantra: viewModel.mantra)
        }
        .sheet(isPresented: $isPresentedStatisticsSheet) {
            StatisticsViewWatch10(
                viewModel: StatisticsViewModel(
                    mantra: viewModel.mantra,
                    dataManager: dataManager
                )
            )
        }
        .onAppear {
            guard !(previousReads == 0 || previousReads == viewModel.mantra.reads) else { return }
            viewModel.checkForCongratulationsOnWatch(with: viewModel.mantra.reads - previousReads)
            previousReads = viewModel.mantra.reads
        }
        .onDisappear {
            if isMantraCounterMode {
                withAnimation {
                    isMantraCounterMode = false
                    viewModel.endMantraCounterSession()
                }
            }
        }
        .navigationTitle(viewModel.mantra.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleMantraCounterMode() {
        withAnimation {
            isMantraCounterMode.toggle()
        }
        WKInterfaceDevice.current().play(.click)
        if isMantraCounterMode {
            viewModel.startMantraCounterSession()
            previousReads = viewModel.mantra.reads
            showHint = true
        } else {
            viewModel.endMantraCounterSession()
            guard !(previousReads == 0 || previousReads == viewModel.mantra.reads) else { return }
            viewModel.checkForCongratulationsOnWatch(with: viewModel.mantra.reads - previousReads, noDelay: true)
        }
    }
}
