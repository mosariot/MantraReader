//
//  ContentView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 19.06.2022.
//

import SwiftUI

struct ContentView: View {   
    @State private var selectedMantra: Mantra?
    
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
            MantraListColumn(selectedMantra: $selectedMantra)
        } detail: {
            DetailsColumn(selectedMantra: selectedMantra)
                .navigationSplitViewColumnWidth(min: 400, ideal: 600)
        }
#if os(macOS)
        .frame(minHeight: 600)
#endif
#if os(iOS)
        .onChange(of: selectedMantra) { [selectedMantra] _ in
            if ((isPad && isPortrait) || (isPhone && isLandscape)) && selectedMantra != nil {
                columnVisibility = .detailOnly
            }
        }
        .onChange(of: orientationInfo.orientation) { _ in
            if isPad && isPortrait {
                columnVisibility = .doubleColumn
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
