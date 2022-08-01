//
//  ContentView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 19.06.2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    @AppStorage("sorting") private var sorting: Sorting = .title
    
    @State private var selectedMantra: Mantra?
    @State private var showingDataFailedAlert = false
    
    @SectionedFetchRequest(sectionIdentifier: \.isFavorite, sortDescriptors: [])
    private var mantras: SectionedFetchResults<Bool, Mantra>
    
#if os(iOS)
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    private var isLandscape: Bool { orientationInfo.orientation == .landscape }
    private var isPortrait: Bool { orientationInfo.orientation == .portrait }
#endif
    
    init() {
        var currentSortDescriptor: SortDescriptor<Mantra>
        switch sorting {
        case .title: currentSortDescriptor = SortDescriptor(\Mantra.title, order: .forward)
        case .reads: currentSortDescriptor = SortDescriptor(\Mantra.reads, order: .reverse)
        }
        self._mantras = SectionedFetchRequest(
            sectionIdentifier: \.isFavorite,
            sortDescriptors: [
                SortDescriptor(\.isFavorite, order: .reverse),
                currentSortDescriptor
            ],
            animation: .default
        )
#if os(iOS)
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = Constants.accentColor
#endif
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            MantraListColumn(mantras: mantras ,selectedMantra: $selectedMantra)
                .onAppear {
                    if !mantras.isEmpty {
#if os(iOS)
                        if ((verticalSizeClass == .regular && horizontalSizeClass == .regular)
                            || (verticalSizeClass == .compact && horizontalSizeClass == .regular))
                            && isFreshLaunch {
                            selectedMantra = mantras[0][0]
                        }
#elseif os(macOS)
                        if isFreshLaunch {
                            selectedMantra = mantras[0][0]
                        }
#endif
                    }
                }
        } detail: {
            DetailsColumn(selectedMantra: selectedMantra)
                .navigationSplitViewColumnWidth(min: 400, ideal: 600)
        }
        .onReceive(NotificationCenter.default.publisher(for: dataSaveFailedNotification)) { _ in
            showingDataFailedAlert = true
        }
        .alert(
            "There was a fatal error in the app and it cannot continue. Press OK to terminate the app. Sorry for inconvenience.",
            isPresented: $showingDataFailedAlert
        ) {
            Button("OK", role: .cancel) {
                let exception = NSException(
                    name: NSExceptionName.internalInconsistencyException,
                    reason: "Fatal Core Data error",
                    userInfo: nil
                )
                exception.raise()
            }
        }
#if os(macOS)
        .frame(minHeight: 600)
#endif
#if os(iOS)
        .onChange(of: selectedMantra) { _ in
            if !isFreshLaunch {
                if ((isPad && isPortrait) || (isPhone && isLandscape))
                    && selectedMantra != nil  {
                    columnVisibility = .detailOnly
                }
            }
            isFreshLaunch = false
        }
#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(OrientationInfo())
    }
}
