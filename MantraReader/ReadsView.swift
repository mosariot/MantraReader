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
        
        GeometryReader { geo in
            VStack {
                layout {
                    Spacer()
                    Image(uiImage: viewModel.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: imageSize(with: geo).width,
                            height: imageSize(with: geo).height
                        )
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
                            viewModel: CircularProgressViewModel(viewModel.mantra)
                        )
                        .frame(
                            width: circularProgressViewSize(with: geo).width,
                            height: circularProgressViewSize(with: geo).height
                        )
                        .padding()
                        GoalButtonView(
                            viewModel: GoalButtonViewModel(viewModel.mantra),
                            adjustingType: $adjustingType,
                            isPresentedAdjustingAlert: $isPresentedAdjustingAlert
                        )
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
        .overlay(alignment: .topTrailing) {
            Button {
                isMantraReaderMode.toggle()
            } label: {
                Image(systemName: "sun.max")
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
    
    private func imageSize(with geo: GeometryProxy) -> (width: CGFloat?, height: CGFloat?) {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular):
            return (0.34 * CGFloat(geo.size.width), nil)
        case (.compact, .compact):
            return (nil, CGFloat(0.45 * geo.size.height))
        case (.regular, .compact):
            return (nil, CGFloat(0.48 * geo.size.height))
        case (.regular, .regular):
            return (nil, CGFloat(0.20 * geo.size.height))
        default:
            return (nil, nil)
        }
    }
    
    private func circularProgressViewSize(with geo: GeometryProxy) -> (width: CGFloat?, height: CGFloat?) {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular):
            return (0.70 * CGFloat(geo.size.width), nil)
        case (.compact, .compact):
            return (nil, 0.53 * CGFloat(geo.size.height))
        case (.regular, .compact):
            return (nil, 0.57 * CGFloat(geo.size.height))
        case (.regular, .regular):
            return (nil, 0.35 * CGFloat(geo.size.height))
        default:
            return (nil, nil)
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
