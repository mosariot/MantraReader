//
//  ContentView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 19.06.2022.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMantra: Mantra?
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @EnvironmentObject var orientationInfo: OrientationInfo
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            MantraListView(selectedMantra: $selectedMantra)
        } detail: {
            DetailsView(selectedMantra: selectedMantra)
        }
#if os(iOS)
        .onChange(of: selectedMantra) { _ in
            if UIDevice.current.userInterfaceIdiom == .pad && orientationInfo.orientation == .portrait {
                columnVisibility = .detailOnly
            }
        }
#elseif os(macOS)
        .frame(minWidth: 600, minHeight: 450)
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
