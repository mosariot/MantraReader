//
//  ReadsView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI

enum AdjustingType {
    case reads
    case rounds
    case value
    case goal
}

struct ReadsView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var viewModel: ReadsViewModel
    @State private var isPresentedAdjustingAlert = false
    @State private var adjustingType: AdjustingType?
    @State private var adjustingText: String = ""
    
#if os(iOS)
    private var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
#endif
    
    var body: some View {
        let layout = (verticalSizeClass == .compact && isPhone) ?
        AnyLayout(_HStackLayout()) :
        AnyLayout(_VStackLayout())
        
        ZStack {
            VStack {
                layout {
                    Spacer()
                    Image(uiImage: viewModel.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
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
                            progress: viewModel.progress,
                            displayedNumber: viewModel.displayedReads,
                            isAnimated: viewModel.isAnimated
                        )
                        .padding(.bottom)
                        Button("Current goal: \(viewModel.displayedGoal, specifier: "%.0f")") {
                            adjustingType = .goal
                            isPresentedAdjustingAlert = true
                        }
                    }
                    Spacer()
                }
                HStack {
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
            }
            .ignoresSafeArea(.keyboard)
            
            if isPresentedAdjustingAlert {
                UpdatingAlertView(
                    isPresented: $isPresentedAdjustingAlert,
                    adjustingText: $adjustingText,
                    adjustingType: $adjustingType,
                    viewModel: viewModel
                )
            }
        }
        .toolbar {
            
        }
    }
}

import CoreData

struct ReadsView_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    static func previewMantra(viewContext: NSManagedObjectContext) -> Mantra {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try mantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return mantras[Int.random(in: 0...mantras.count-1)]
    }
    
    static var previews: some View {
        ReadsView(
            viewModel: ReadsViewModel(
                previewMantra(viewContext: controller.container.viewContext),
                viewContext: controller.container.viewContext
            )
        )
    }
}
