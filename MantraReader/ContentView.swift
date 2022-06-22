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
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @ObservedObject var orientationInfo = OrientationInfo()
#endif
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            MantraListView(selectedMantra: $selectedMantra)
        } detail: {
            DetailsView(selectedMantra: selectedMantra)
                .navigationSplitViewColumnWidth(min: 400, ideal: 600)
        }
        .frame(minHeight: 450)
#if os(iOS)
        .onChange(of: selectedMantra) { _ in
            if (UIDevice.current.userInterfaceIdiom == .pad && orientationInfo.orientation == .portrait) ||
                (UIDevice.current.userInterfaceIdiom == .phone && orientationInfo.orientation == .landscape) {
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
    }
}
