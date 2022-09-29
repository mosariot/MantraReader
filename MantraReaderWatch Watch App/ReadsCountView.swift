//
//  ReadsView.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 23.09.2022.
//

import SwiftUI

struct ReadsView: View {
    @AppStorage("isFirstLaunchOfMantraCounterMode") private var isFirstLaunchOfMantraCounterMode = true
    @EnvironmentObject private var dataManager: DataManager
    @ObservedObject var viewModel: ReadsViewModel
    
    @State private var isPresentedStatisticsSheet = false
    @State private var isPresentedInfoSheet = false
    @State private var isPresentedInfoAlert = false
    @State private var isPresentedMantraCounterModeAlert = false
    @State private var isPresentedMantraCounterModeInfo = false
    @State private var isPresentedAdjustingSheet = false
    @State private var isMantraCounterMode = false
    @State private var showBlink = false
    @State private var showHint = false
    @State private var currentReads: Int32 = 0
    
    init(viewModel: ReadsViewModel) {
        self.viewModel = viewModel
    }
    
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
                viewModel: CircularProgressViewModel(viewModel.mantra, currentReads: $currentReads),
                isMantraCounterMode: isMantraCounterMode,
                currentReads: $currentReads
            )
            .padding(.top, 10)
            .padding(.bottom, 10)
            VStack {
                Spacer()
                HStack {
                    Button {
                        isPresentedAdjustingSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 37))
                            .symbolVariant(.circle.fill)
                            .foregroundStyle(Color.accentColor.gradient)
                    }
                    .controlSize(.mini)
                    .buttonStyle(.borderless)
                    .padding(.bottom, -20)
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
                    .padding(.bottom, -20)
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
            .padding(.horizontal)
            .alert("'Mantra Counter' Mode", isPresented: $isPresentedMantraCounterModeInfo) {
                Button("OK") { }
            } message: {
                Text("Use long press on the screen to enter and quit the mode.")
            }
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
            Text("You are entering the 'Mantra Counter' mode. Single tap on the screen will add one reading, double tap will add one round. Use extended Wake Duration in your Watch Settings to prevent screen dimming.")
        }
        .sheet(isPresented: $isPresentedAdjustingSheet) {
            AdjustingView(viewModel: viewModel)
        }
        .sheet(isPresented: $isPresentedInfoSheet) {
            InfoView(mantra: viewModel.mantra)
        }
        .sheet(isPresented: $isPresentedStatisticsSheet) {
            StatisticsView(
                viewModel: StatisticsViewModel(
                    mantra: viewModel.mantra,
                    dataManager: dataManager
                )
            )
        }
        .onDisappear {
            if isMantraCounterMode {
                withAnimation {
                    isMantraCounterMode = false
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
        if isMantraCounterMode {
            WKInterfaceDevice.current().play(.click)
            showHint = true
            afterDelay(1.5) { showHint = false }
        }
    }
}
