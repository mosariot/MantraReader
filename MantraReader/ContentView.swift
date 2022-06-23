//
//  ContentView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 19.06.2022.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    
    @State private var selectedMantra: Mantra?
    
#if os(iOS)
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @EnvironmentObject var orientationInfo: OrientationInfo
#endif
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            MantraListView(selectedMantra: $selectedMantra)
        } detail: {
            DetailsView(selectedMantra: selectedMantra)
                .navigationSplitViewColumnWidth(min: 400, ideal: 600)
        }
        .frame(minHeight: 450)
        .onAppear {
            if isFirstLaunch {
                /// TODO:
                /// onboarding
                /// checking for iCloud
                /// preloading mantras
                isFirstLaunch = false }
            isFreshLaunch = true
        }
#if os(iOS)
        .onChange(of: selectedMantra) { [selectedMantra] _ in
            if ((UIDevice.current.userInterfaceIdiom == .pad && orientationInfo.orientation == .portrait) ||
                (UIDevice.current.userInterfaceIdiom == .phone && orientationInfo.orientation == .landscape)) && selectedMantra != nil {
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
