//
//  ContentView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 19.06.2022.
//

import SwiftUI

struct ContentView: View {   
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    @State private var selectedMantra: Mantra?
    @State private var showingDataFailedAlert = false
    
#if os(iOS)
    @EnvironmentObject var orientationInfo: OrientationInfo
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    private var isLandscape: Bool { orientationInfo.orientation == .landscape }
    private var isPortrait: Bool { orientationInfo.orientation == .portrait }
#endif
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
//            MantraListColumn(selectedMantra: $selectedMantra)
            MantraListColumnNative(selectedMantra: $selectedMantra)
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
        .onChange(of: selectedMantra) { [selectedMantra] _ in
            if isFreshLaunch { isFreshLaunch = false }
            if ((isPad && isPortrait) || (isPhone && isLandscape)) && selectedMantra != nil {
                columnVisibility = .detailOnly
            }
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
