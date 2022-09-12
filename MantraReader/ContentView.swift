//
//  ContentView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 19.06.2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @EnvironmentObject private var dataManager: DataManager
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    @AppStorage("isInitalDataLoading") private var isInitalDataLoading = true
    @AppStorage("sorting") private var sorting: Sorting = .title
    
    @State private var selectedMantra: Mantra?
    @State private var search = ""
    @State private var isMantraDeleted = false
    
    @SectionedFetchRequest(sectionIdentifier: \.isFavorite, sortDescriptors: [])
    private var mantras: SectionedFetchResults<Bool, Mantra>
    
    @State private var orientationInfo = OrientationInfo()
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    private var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    private var isLandscape: Bool { orientationInfo.orientation == .landscape }
    private var isPortrait: Bool { orientationInfo.orientation == .portrait }
    
    init() {
        var currentSortDescriptor: SortDescriptor<Mantra>
        switch sorting {
        case .title: currentSortDescriptor = SortDescriptor(\.title, order: .forward)
        case .reads: currentSortDescriptor = SortDescriptor(\.reads, order: .reverse)
        }
        self._mantras = SectionedFetchRequest(
            sectionIdentifier: \.isFavorite,
            sortDescriptors: [
                SortDescriptor(\.isFavorite, order: .reverse),
                currentSortDescriptor
            ],
            predicate: NSPredicate(format: "title != %@", ""),
            animation: .default
        )
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = Constants.accentColor
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ZStack {
                MantraListColumn(
                    mantras: mantras,
                    sorting: sorting,
                    selectedMantra: $selectedMantra,
                    searchText: $search
                )
                .searchable(text: $search)
                .onChange(of: search) {
                    mantras.nsPredicate = $0.isEmpty ? nil : NSPredicate(format: "title contains[cd] %@", $0)
                }
                if isInitalDataLoading {
                    ProgressView("Syncing...")
                }
            }
            .onAppear {
                if !mantras.isEmpty {
                    if ((verticalSizeClass == .regular && horizontalSizeClass == .regular)
                        || (verticalSizeClass == .compact && horizontalSizeClass == .regular))
                        && isFreshLaunch {
                        selectedMantra = mantras[0][0]
                    }
                }
                dataManager.deleteEmptyMantrasIfNeeded()
            }
            .onOpenURL { url in
                mantras.forEach { section in
                    section.forEach { mantra in
                        if mantra.uuid == UUID(uuidString: "\(url)") {
                            selectedMantra = mantra
                        }
                    }
                }
            }
            .onReceive(mantras.publisher.count()) { count in
                if isInitalDataLoading && count > 0 {
                    isInitalDataLoading = false
                }
            }
        } detail: {
            DetailsColumn(selectedMantra: selectedMantra, isMantraDeleted: $isMantraDeleted)
                .navigationSplitViewColumnWidth(min: 400, ideal: 600)
        }
        .onChange(of: selectedMantra) { _ in
            if !isFreshLaunch {
                if ((isPad && isPortrait) || (isPhone && isLandscape))
                    && selectedMantra != nil  {
                    columnVisibility = .detailOnly
                }
            }
            isFreshLaunch = false
        }
        .onChange(of: isMantraDeleted) { newValue in
            if newValue {
                selectedMantra = nil
            }
        }
    }
}
