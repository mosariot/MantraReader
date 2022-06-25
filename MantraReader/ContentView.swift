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
