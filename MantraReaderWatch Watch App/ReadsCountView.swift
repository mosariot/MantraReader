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
    @State private var isPresentedMantraCounterModeInfo = false
    @State private var isPresentedMantraCounterModeAlert = false
    @State private var isMantraCounterMode = false
    @State private var showBlink = false
    @State private var showHint = false
    
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
            VStack {
                Text("\(viewModel.mantra.title ?? "")")
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.bottom, 10)
                ZStack {
                    ProgressRing(progress: viewModel.progress, thickness: 15)
                        .animation(.easeInOut(duration: Constants.animationTime), value: viewModel.progress)
                    Text("Reads")
                        .numberAnimation(viewModel.mantra.reads)
                        .animation(
                            viewModel.isAnimated ?
                                Animation.easeInOut(duration: Constants.animationTime) :
                                Animation.linear(duration: 0.01),
                            value: viewModel.mantra.reads)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .dynamicTypeSize(.xLarge)
                        .opacity(isMantraCounterMode ? 0 : 1)
                    Text("Current Reads")
                        .numberAnimation(Int32(viewModel.currentReads))
                        .animation(
                            viewModel.isAnimated ?
                                Animation.easeInOut(duration: Constants.animationTime) :
                                Animation.linear(duration: 0.01),
                            value: viewModel.mantra.reads)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(.accentColor)
                        .dynamicTypeSize(.xLarge)
                        .opacity(isMantraCounterMode ? 1 : 0)
                }
                .padding(.bottom, -25)
                HStack {
                    Button {
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 35))
                            .symbolVariant(.circle.fill)
                            .foregroundStyle(Color.accentColor.gradient)
                    }
                    .controlSize(.mini)
                    .buttonStyle(.borderless)
                    Spacer()
                    Button {
                        isPresentedInfoAlert = true
                    } label: {
                        Image(systemName: "info")
                            .symbolVariant(.circle)
                            .font(.system(size: 35))
                            .foregroundStyle(Color.accentColor.gradient)
                    }
                    .controlSize(.mini)
                    .buttonStyle(.borderless)
                    .alert("Select an option", isPresented: $isPresentedInfoAlert) {
                        Button("Mantra Info") {
                            isPresentedInfoSheet = true
                        }
                        Button("Statistics") {
                            isPresentedStatisticsSheet = true
                        }
                        Button("Mantra Counter") {
                            isPresentedMantraCounterModeInfo = true
                        }
                        Button("Dismiss") { }
                    }
                }
                .padding(.horizontal)
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
            .alert("Mantra Counter mode", isPresented: $isPresentedMantraCounterModeInfo) {
                Button("OK") { }
            } message: {
                Text("Use long press on the screen to enter and quit the mode")
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
        .sheet(isPresented: $isPresentedInfoSheet) {
            InfoView(mantra: mantra)
        }
        .sheet(isPresented: $isPresentedStatisticsSheet) {
            StatisticsView(
                viewModel: StatisticsViewModel(
                    mantra: viewModel.mantra,
                    dataManager: dataManager
                )
            )
        }
        .onReceive(viewModel.mantra.objectWillChange) { _ in
            withAnimation {
                viewModel.updateForMantraChanges()
            }
        }
        .onDisappear {
            if isMantraCounterMode {
                withAnimation {
                    isMantraCounterMode = false
                }
            }
        }
    }
    
    private func toggleMantraCounterMode() {
        withAnimation {
            isMantraCounterMode.toggle()
        }
        if isMantraCounterMode {
            WKInterfaceDevice.currentDevice().playHaptic(.start)
            showHint = true
            afterDelay(1.5) { showHint = false }
        }
    }
}

struct InfoView: View {
    @ObservedObject var mantra: Mantra
    
    private var image: UIImage {
        if let data = mantra.image, let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(named: Constants.defaultImage)!
        }
    }
    
    var body: some View {
        List {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
            Section("TITLE") {
                Text(mantra.title ?? "")
            }
            Section("MANTRA TEXT") {
                Text(mantra.text ?? "")
            }
            Section("DESCRIPTION") {
                Text(mantra.details ?? "")
            }
        }
    }
}
