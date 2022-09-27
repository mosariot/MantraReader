//
//  DetailsColumn.swift
//  MantraReaderWatch Watch App
//
//  Created by Alex Vorobiev on 23.09.2022.
//

import SwiftUI

struct ReadsCountView: View {
    @EnvironmentObject private var dataManager: DataManager
    @ObservedObject var viewModel: ReadsCountViewModel
    
    @State private var isPresentedStatisticsSheet = false
    
    var body: some View {
        ZStack {
            VStack {
                Text("\(viewModel.mantra.title ?? "")")
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.bottom, 10)
                ZStack {
                    ProgressRing(progress: viewModel.progress, thickness: 15)
                        .animation(.easeInOut(duration: Constants.animationTime), value: viewModel.mantra.reads)
                    Text("Reads")
                        .numberAnimation(viewModel.mantra.reads)
                        .animation(.easeInOut(duration: Constants.animationTime), value: viewModel.mantra.reads)
                        .font(
                            .system(.title3, design: .rounded, weight: .bold)
                        )
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
                        isPresentedStatisticsSheet = true
                    } label: {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.accentColor.gradient)
                    }
                    .controlSize(.mini)
                    .buttonStyle(.borderless)
                }
                .padding(.horizontal)
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
        }
    }
}
