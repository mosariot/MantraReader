//
//  ReadsView.swift
//  MantraReader
//
//  Created by Александр Воробьев on 17.06.2022.
//

import SwiftUI

enum AdjustingType {
    case reads
    case rounds
    case value
    case goal
}

struct ReadsView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @ObservedObject var viewModel: ReadsViewModel
    @State private var isPresentedAdjustingAlert = false
    @State private var adjustingType: AdjustingType?
    @State private var adjustingText: String = ""
    
#if os(iOS)
    private var isPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
#endif
    
    var body: some View {
        let layout = (verticalSizeClass == .compact && isPhone) ? AnyLayout(_HStackLayout()) : AnyLayout(_VStackLayout())
        
        ZStack {
            VStack {
                layout {
                    Image(uiImage: viewModel.image)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxHeight: 200)
                    
                    if verticalSizeClass == .regular {
                        Text(viewModel.title)
                            .font(.title)
                            .padding()
                    }
                    
                    CircularProgressView(
                        progress: viewModel.progress,
                        displayedNumber: viewModel.displayedReads,
                        displayedGoal: viewModel.displayedGoal,
                        isAnimated: viewModel.isAnimated
                    )
                }
                
                HStack {
                    Button {
                        adjustingType = .reads
                        isPresentedAdjustingAlert = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 60))
                            .symbolVariant(.circle.fill)
                    }
                    .padding()
                    Button {
                        adjustingType = .rounds
                        isPresentedAdjustingAlert = true
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 60))
                            .symbolVariant(.circle.fill)
                    }
                    .padding()
                    Button {
                        adjustingType = .value
                        isPresentedAdjustingAlert = true
                    } label: {
                        Image(systemName: "hand.draw")
                            .font(.system(size: 60))
                            .symbolVariant(.fill)
                    }
                    .padding()
                }
            }
            .ignoresSafeArea(.keyboard)
            
            if isPresentedAdjustingAlert {
                UpdatingAlertView(
                    isPresented: $isPresentedAdjustingAlert,
                    adjustingText: $adjustingText,
                    adjustingType: $adjustingType,
                    viewModel: viewModel
                )
            }
        }
    }
}

import CoreData

struct ReadsView_Previews: PreviewProvider {
    static var controller = PersistenceController.preview
    static func previewMantra(viewContext: NSManagedObjectContext) -> Mantra {
        var mantras = [Mantra]()
        let request = NSFetchRequest<Mantra>(entityName: "Mantra")
        do {
            try mantras = viewContext.fetch(request)
        } catch {
            print("Error getting data. \(error.localizedDescription)")
        }
        return mantras[Int.random(in: 0...mantras.count-1)]
    }
    
    static var previews: some View {
        ReadsView(
            viewModel: ReadsViewModel(
                previewMantra(viewContext: controller.container.viewContext),
                viewContext: controller.container.viewContext
            )
        )
    }
}

import UIKit

struct UpdatingAlertView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var adjustingText: String
    @Binding var adjustingType: AdjustingType?
    var viewModel: ReadsViewModel
    
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<UpdatingAlertView>
    ) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: UIViewControllerRepresentableContext<UpdatingAlertView>
    ) {
        guard context.coordinator.alert == nil else { return }
        
        if isPresented {
            var adjustingNumber: Int32 = 0
            let (alertTitle, actionTitle) = viewModel.alertAndActionTitles(for: adjustingType)
            
            let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
            context.coordinator.alert = alert
            
            let positiveAction = UIAlertAction(title: actionTitle, style: .default) { _ in
                viewModel.handleAdjusting(for: adjustingType, with: adjustingNumber)
                alert.dismiss(animated: true) {
                    adjustingType = nil
                    adjustingText = ""
                    isPresented = false
                }
            }
            
            alert.addTextField { alertTextField in
                alertTextField.placeholder = "Enter number"
                alertTextField.keyboardType = .numberPad
                alertTextField.clearButtonMode = .always
                alertTextField.delegate = context.coordinator
                positiveAction.isEnabled = false
                NotificationCenter.default
                    .addObserver(
                        forName: UITextField.textDidChangeNotification,
                        object: alertTextField,
                        queue: .main
                    ) { _ in
                        if viewModel.isValidUpdatingNumber(
                            text: alertTextField.text,
                            adjustingType: adjustingType
                        ) {
                            positiveAction.isEnabled = true
                            guard
                                let textValue = alertTextField.text,
                                let numberValue = Int32(textValue)
                            else { return }
                            adjustingNumber = numberValue
                        } else {
                            positiveAction.isEnabled = false
                        }
                    }
            }
            
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Alert Button on ReadsView"),
                style: .default
            ) { _ in
                alert.dismiss(animated: true) {
                    adjustingType = nil
                    adjustingText = ""
                    isPresented = false
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(positiveAction)
            alert.view.tintColor = Constants.accentColor ?? .systemOrange
            
            DispatchQueue.main.async {
                uiViewController.present(alert, animated: true) {
                    adjustingType = nil
                    adjustingText = ""
                    isPresented = false
                    context.coordinator.alert = nil
                }
            }
        }
    }
    
    func makeCoordinator() -> UpdatingAlertView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var alert: UIAlertController?
        var view: UpdatingAlertView
        
        init(_ view: UpdatingAlertView) {
            self.view = view
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
            return true
        }
    }
}
