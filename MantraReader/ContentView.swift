//
//  ContentView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 19.06.2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedMantra: Mantra?
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var orientation = UIDevice.current.orientation
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            MantraListView(selectedMantra: $selectedMantra)
        } detail: {
            DetailsView(selectedMantra: selectedMantra)
        }
#if os(iOS)
        .onChange(of: selectedMantra) { _ in
            if UIDevice.current.userInterfaceIdiom == .pad && orientation.isPortrait {
                columnVisibility = .detailOnly
            }
        }
        .detectOrientation($orientation)
#elseif os(macOS)
        .frame(minWidth: 600, minHeight: 450)
#endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct OrientationDetector: ViewModifier {
  @Binding var orientation: UIDeviceOrientation

  func body(content: Content) -> some View {
    content
      .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
        orientation = UIDevice.current.orientation
      }
  }
}

extension View {
  func detectOrientation(_ binding: Binding<UIDeviceOrientation>) -> some View {
    self.modifier(OrientationDetector(orientation: binding))
  }
}
