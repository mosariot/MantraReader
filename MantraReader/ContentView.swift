//
//  ContentView.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 19.06.2022.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @EnvironmentObject private var dataManager: DataManager
    @EnvironmentObject private var settings: Settings
    @AppStorage("sorting", store: UserDefaults(suiteName: "group.com.mosariot.MantraCounter"))
    var sorting: Sorting = .title
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    
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
                    selectedMantra: $selectedMantra,
                    searchText: $search
                )
                .searchable(text: $search)
                .onChange(of: search) {
                    mantras.nsPredicate = $0.isEmpty ? nil : NSPredicate(format: "title contains[cd] %@", $0)
                }
                .onChange(of: settings.sorting) {
                    switch $0 {
                    case .title: mantras.sortDescriptors = [
                        SortDescriptor(\.isFavorite, order: .reverse),
                        SortDescriptor(\.title, order: .forward)
                    ]
                    case .reads: mantras.sortDescriptors = [
                        SortDescriptor(\.isFavorite, order: .reverse),
                        SortDescriptor(\.reads, order: .reverse)
                    ]
                    }
                    dataManager.saveData()
                }
                if isFirstLaunch {
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
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    UIApplication.shared.connectedScenes.forEach { scene in
                        if scene.activationState == .foregroundActive {
                            let rootViewController = UIApplication.shared.connectedScenes
                                .filter { $0.activationState == .foregroundActive }
                                .map { $0 as? UIWindowScene }
                                .compactMap { $0 }
                                .first?.windows
                                .filter({ $0.isKeyWindow }).first?.rootViewController
                            rootViewController?.dismiss(animated: true) {
                                mantras.forEach { section in
                                    section.forEach { mantra in
                                        if mantra.uuid == UUID(uuidString: "\(url)") {
                                            selectedMantra = mantra
                                        }
                                    }
                                }
                            }
                            timer.invalidate()
                        }
                    }
                }
            }
            .onReceive(mantras.publisher.count()) { count in
                if isFirstLaunch && count > 0 {
                    isFirstLaunch = false
                }
                var isMantraExist = false
                mantras.forEach { section in
                    section.forEach { mantra in
                        if mantra == selectedMantra {
                            isMantraExist = true
                        }
                    }
                }
                if !isMantraExist {
                    selectedMantra = nil
                }
            }
        } detail: {
            DetailsColumn(selectedMantra: selectedMantra, isMantraDeleted: $isMantraDeleted)
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
