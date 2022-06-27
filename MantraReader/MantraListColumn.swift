//
//  MantraListColumn.swift
//  MantraReader
//
//  Created by Александр Воробьев on 21.06.2022.
//

import SwiftUI

struct MantraListColumn: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var orientationInfo: OrientationInfo
    @AppStorage("isFreshLaunch") private var isFreshLaunch = true
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Mantra.title, ascending: true)],
        animation: .default)
    private var mantras: FetchedResults<Mantra>
    
    @Binding var selectedMantra: Mantra?
    
    var body: some View {
        List(selection: $selectedMantra) {
            ForEach(mantras) { mantra in
                NavigationLink(value: mantra) {
                    HStack {
                        Image(uiImage: image(for: mantra))
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: CGFloat(Constants.rowHeight))
                        VStack(alignment: .leading) {
                            Text(mantra.title!)
                            Text("Current reads: \(mantra.reads)")
                                .font(.caption)
                                .opacity(0.5)
                        }
                        Spacer()
                        if mantra.reads >= mantra.readsGoal {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .onAppear {
            if let mantra = mantras.first {
#if os(iOS)
                if (UIDevice.current.userInterfaceIdiom == .phone &&
                    orientationInfo.orientation == .portrait) ||
                    (UIDevice.current.userInterfaceIdiom == .phone &&
                        orientationInfo.orientation == .landscape &&
                    !isFreshLaunch) {
                    isFreshLaunch = false
                    return
                }
#endif
                selectedMantra = mantra
                if isFreshLaunch { isFreshLaunch = false }
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
#endif
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Mantra Reader")
    }
    
    private func image(for mantra: Mantra) -> UIImage {
        if let imageData = mantra.imageForTableView {
            return UIImage(data: imageData)!
        } else {
            return UIImage(named: Constants.defaultImage)!.resize(
                to: CGSize(width: Constants.rowHeight,
                           height: Constants.rowHeight))
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { mantras[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func addItem() {
        withAnimation {
            let newMantra = Mantra(context: viewContext)
            newMantra.uuid = UUID()
            newMantra.reads = Int32.random(in: 0...100_000)
            newMantra.title = "Some Mantra"
            newMantra.text = "Some Text"
            newMantra.details = "Some Details"
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct MantraListView_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    
    static var previews: some View {
        NavigationView {
            MantraListColumn(selectedMantra: .constant(nil))
                .environment(\.managedObjectContext, controller.container.viewContext)
                .environmentObject(OrientationInfo())
        }
    }
}


